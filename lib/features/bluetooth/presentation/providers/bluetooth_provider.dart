import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/snack_bar_service.dart';
import '../../data/services/ble_service.dart';
import '../../domain/entities/ble_device_item.dart';

/// State of the device-list screen: adapter on/off, scanning, the merged device list and connecting.
class BluetoothProvider extends ChangeNotifier with WidgetsBindingObserver {
  BluetoothProvider(this._ble, this._navigation, this._dialogs, this._snackBar);

  final BleService _ble;
  final NavigationService _navigation;
  final DialogService _dialogs;
  final SnackBarService _snackBar;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  DateTime? _lastScanTime;
  bool _isDisposed = false;

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _isScanning = false;
  bool _isTurningOn = false;
  List<ScanResult> _scanResults = const [];

  BluetoothAdapterState get adapterState => _adapterState;
  bool get isAdapterOn => _adapterState == BluetoothAdapterState.on;
  bool get isScanning => _isScanning;
  bool get isTurningOn => _isTurningOn;

  /// Connected manikins first, then every named device found by the scan with manikins on top, strongest signal first.
  /// Nothing is filtered by name, so the list works on every Android version and every manikin firmware.
  List<BleDeviceItem> get devices {
    final connected = _ble.connectedDevices;
    String nameOf(BluetoothDevice d, ScanResult? r) {
      if (d.advName.isNotEmpty) return d.advName;
      if (d.platformName.isNotEmpty) return d.platformName;
      return r?.advertisementData.advName ?? '';
    }

    final items = <BleDeviceItem>[
      for (final device in connected)
        () {
          final result = _scanResults.where((r) => r.device.remoteId == device.remoteId).firstOrNull;
          return BleDeviceItem(device: device, name: nameOf(device, result).ifEmpty('Unknown device'), isManikin: result == null ? true : _ble.isManikin(result), rssi: result?.rssi);
        }(),
    ];

    final found = _scanResults.where((r) => !connected.any((d) => d.remoteId == r.device.remoteId) && nameOf(r.device, r).isNotEmpty).toList()
      ..sort((a, b) {
        if (_ble.isManikin(a) != _ble.isManikin(b)) return _ble.isManikin(a) ? -1 : 1;
        return b.rssi.compareTo(a.rssi);
      });
    for (final r in found) {
      items.add(BleDeviceItem(device: r.device, name: nameOf(r.device, r), isManikin: _ble.isManikin(r), rssi: r.rssi));
    }
    return items;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    _subscriptions
      ..add(_ble.isScanning.listen((value) {
        _isScanning = value;
        _notify();
      }))
      ..add(_ble.scanResults.listen((results) {
        _scanResults = results;
        _notify();
      }))
      ..add(_ble.connectionEvents.listen((_) => _notify()))
      ..add(_ble.adapterState.listen(_onAdapterState));

    if (!await _ble.isSupported) {
      _snackBar.show('Bluetooth not supported by this device');
      return;
    }
    await FlutterBluePlus.setLogLevel(LogLevel.none, color: false);
    await _ble.requestPermissions(onPermanentlyDenied: _showPermissionDialog);
  }

  Future<void> _onAdapterState(BluetoothAdapterState state) async {
    _adapterState = state;
    _notify();
    if (state == BluetoothAdapterState.on) {
      // A manikin that is already connected is listed straight away, so no scan is needed.
      if (_ble.connectedDevices.isEmpty && await _ble.hasPermissions()) scan();
    } else {
      _ble.stopScan();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _ble.stopScan();
    } else if (state == AppLifecycleState.resumed) {
      _onResumed();
    }
  }

  /// Back from the system settings after granting permissions: start scanning that was skipped.
  Future<void> _onResumed() async {
    if (!await _ble.hasPermissions()) return;
    if (isAdapterOn) scan();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  /// Starts a scan (ignored if requested again within 1.5 s).
  Future<void> scan() async {
    final now = DateTime.now();
    if (_lastScanTime != null && now.difference(_lastScanTime!).inMilliseconds < 1500) return;
    _lastScanTime = now;
    try {
      await _ble.startScan();
    } on FlutterBluePlusException catch (e) {
      debugPrint('BLE scan error (${e.code}): ${e.description}');
      if (e.code == 2) _snackBar.show('Bluetooth was turned off. Please turn it back on.');
    } catch (e) {
      debugPrint('BluetoothProvider.scan: $e');
      await _ble.stopScan();
    }
  }

  Future<void> turnOnBluetooth() async {
    _isTurningOn = true;
    _notify();
    try {
      await _ble.turnOnBluetooth();
    } catch (e) {
      debugPrint('turnOnBluetooth: $e');
      _snackBar.show('Could not enable Bluetooth. Please turn it on manually.');
    } finally {
      _isTurningOn = false;
      _notify();
    }
  }

  /// Connects to [device] and opens the CPR game.
  Future<void> connect(BluetoothDevice device) async {
    if (!isAdapterOn) {
      _snackBar.show('Please turn on Bluetooth first');
      return;
    }
    _dialogs.showProgress(device.isConnected ? 'Opening game' : 'Connecting');
    try {
      await _ble.connect(device);
      await _dialogs.hideProgress();
      _snackBar.show('${device.advName.isEmpty ? device.platformName : device.advName} connected');
      _navigation.replaceWithCpr(device);
    } on TimeoutException {
      await _fail(device, 'Connection timed out. Try again.');
    } catch (_) {
      await _fail(device, 'Could not connect. Try again.');
    }
  }

  Future<void> _fail(BluetoothDevice device, String message) async {
    await _dialogs.hideProgress();
    _snackBar.show(message);
    try {
      await device.disconnect();
    } catch (_) {}
  }

  void goBack() => _navigation.back();

  Future<void> openBluetoothSettings() => _ble.turnOnBluetooth();

  void _showPermissionDialog() {
    _dialogs.show<void>((context) => AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text('Bluetooth (Nearby devices) permission is permanently denied.\n\nPlease open App Settings and grant it.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _ble.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ));
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    for (final s in _subscriptions) {
      s.cancel();
    }
    _ble.stopScan();
    super.dispose();
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
