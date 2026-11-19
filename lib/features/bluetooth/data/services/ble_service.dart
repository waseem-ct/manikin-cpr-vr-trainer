import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

import '../../../../core/config/app_env.dart';

/// Everything Bluetooth: permissions, scanning, connecting, the manikin data stream and reconnecting.
///
/// Packets are delivered to the handler given to [startDataStream]. The handler is remembered, so after a
/// dropped connection [reconnectAndResume] re-attaches the very same stream without the game screen knowing
/// anything about GATT services.
class BleService {
  BleService() {
    _LifecycleGuard.ensureStarted();
  }


  StreamSubscription<List<int>>? _dataSubscription;

  // Remembered so the stream can be resumed after a reconnect.
  BluetoothDevice? _lastDevice;
  void Function(List<String> packet)? _lastHandler;

  /// True while the app itself disconnects the manikin (exit), so no "connection lost" dialog is raised.
  bool isIntentionalDisconnect = false;

  // ── Adapter + scan streams ─────────────────────────────────────────────────
  Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;
  BluetoothAdapterState get adapterStateNow => FlutterBluePlus.adapterStateNow;
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;
  bool get isScanningNow => FlutterBluePlus.isScanningNow;
  List<BluetoothDevice> get connectedDevices => FlutterBluePlus.connectedDevices;

  /// Fires on every connect / disconnect of any device (used to refresh the device list).
  Stream<OnConnectionStateChangedEvent> get connectionEvents => FlutterBluePlus.events.onConnectionStateChanged;

  Future<bool> get isSupported => FlutterBluePlus.isSupported;

  // ── Permissions ────────────────────────────────────────────────────────────
  /// Android 12+ only needs the "Nearby devices" permissions (scan + connect); Android 11 and older need Location
  /// for BLE scanning. Only scan + connect gate scanning, so Location can never block it on new phones.
  Future<bool> hasPermissions() async {
    if (!Platform.isAndroid) return true;
    return await perm.Permission.bluetoothScan.isGranted && await perm.Permission.bluetoothConnect.isGranted;
  }

  /// Asks for the permissions. Returns true when scanning is allowed; [onPermanentlyDenied] runs if the user
  /// has blocked the permission for good (the only way out is the system settings).
  Future<bool> requestPermissions({required VoidCallback onPermanentlyDenied}) async {
    if (!Platform.isAndroid) return true;
    if (!await hasPermissions()) {
      await [perm.Permission.bluetoothScan, perm.Permission.bluetoothConnect, perm.Permission.location].request();
      if (await perm.Permission.bluetoothScan.isPermanentlyDenied || await perm.Permission.bluetoothConnect.isPermanentlyDenied) onPermanentlyDenied();
    } else if (await perm.Permission.location.isDenied) {
      perm.Permission.location.request(); // only needed on old Android; harmless on new versions
    }
    return hasPermissions();
  }

  Future<void> openAppSettings() => perm.openAppSettings();

  Future<void> turnOnBluetooth() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    } else {
      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    }
  }

  // ── Scan ───────────────────────────────────────────────────────────────────
  Future<void> startScan() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
      await Future.delayed(const Duration(milliseconds: 600)); // let the native stack settle
    }
    await FlutterBluePlus.startScan(
      androidScanMode: AndroidScanMode.lowLatency,
      androidLegacy: false, // also finds extended advertisements used by newer phones / firmware
      continuousUpdates: true,
      continuousDivisor: 1,
      timeout: const Duration(seconds: 12),
      androidUsesFineLocation: false,
    );
  }

  Future<void> stopScan() async {
    if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
  }

  /// True when [result] looks like one of our manikins (name contains the configured keyword).
  bool isManikin(ScanResult result) {
    final keyword = AppEnv.bleDeviceNameKeyword.toUpperCase();
    return '${result.device.advName} ${result.device.platformName} ${result.advertisementData.advName}'.toUpperCase().contains(keyword);
  }

  // ── Connect ────────────────────────────────────────────────────────────────
  Future<void> connect(BluetoothDevice device) async {
    isIntentionalDisconnect = false;
    await stopScan();
    if (!device.isConnected) {
      await device.connect(timeout: const Duration(seconds: 6), autoConnect: false);
    }
  }

  /// Disconnects the manikin on purpose (game exit).
  Future<void> disconnect(BluetoothDevice device) async {
    isIntentionalDisconnect = true;
    try {
      if (device.isConnected) {
        try {
          await device.clearGattCache();
        } catch (e) {
          debugPrint('clearGattCache failed: $e');
        }
        await device.disconnect();
      }
    } catch (e) {
      debugPrint('BleService.disconnect: $e');
    } finally {
      await _dataSubscription?.cancel();
      _dataSubscription = null;
      _lastHandler = null;
    }
  }

  // ── Manikin data stream ────────────────────────────────────────────────────
  /// Subscribes to the manikin's characteristic and delivers each packet, already split into its fields.
  Future<void> startDataStream({required BluetoothDevice device, required void Function(List<String> packet) onPacket}) async {
    isIntentionalDisconnect = false;
    _lastDevice = device;
    _lastHandler = onPacket;
    final serviceUuid = AppEnv.bleServiceUuid.toUpperCase();
    final characteristicUuid = AppEnv.bleCharacteristicUuid.toUpperCase();

    try {
      final services = await device.discoverServices();
      for (final service in services) {
        if (!service.serviceUuid.toString().toUpperCase().contains(serviceUuid)) continue;
        for (final characteristic in service.characteristics) {
          if (!characteristic.uuid.toString().toUpperCase().contains(characteristicUuid)) continue;

          await characteristic.setNotifyValue(true);
          await _dataSubscription?.cancel();
          // onValueReceived: no cached replay, fires on real hardware events only
          _dataSubscription = characteristic.onValueReceived.listen(
            (data) {
              if (!_LifecycleGuard.isAppActive) return; // ignore packets while the app is in the background
              final resumedAt = _LifecycleGuard.lastResumeTime;
              if (resumedAt != null && DateTime.now().difference(resumedAt).inMilliseconds < 1000) return; // buffer flush right after resume
              if (data.isEmpty) return;
              try {
                onPacket(ascii.decode(data, allowInvalid: true).split(','));
              } catch (e) {
                debugPrint('BLE packet error: $e');
              }
            },
            onError: (Object e) => debugPrint('BLE data stream error: $e'),
            cancelOnError: false,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('BleService.startDataStream: $e');
    }
  }

  /// Switches the manikin's data notifications on or off (off while the result is shown, on again for a retry).
  Future<void> setNotifications(BluetoothDevice device, {required bool enabled}) async {
    try {
      final serviceUuid = AppEnv.bleServiceUuid.toUpperCase();
      final characteristicUuid = AppEnv.bleCharacteristicUuid.toUpperCase();
      for (final service in await device.discoverServices()) {
        if (!service.uuid.toString().toUpperCase().contains(serviceUuid)) continue;
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toUpperCase().contains(characteristicUuid)) await characteristic.setNotifyValue(enabled);
        }
      }
    } catch (e) {
      debugPrint('BleService.setNotifications: $e');
    }
  }

  /// Reconnects to the last manikin and re-attaches the same packet handler.
  Future<bool> reconnectAndResume() async {
    final device = _lastDevice;
    final handler = _lastHandler;
    if (device == null || handler == null) return false;
    try {
      if (!device.isConnected) await device.connect(timeout: const Duration(seconds: 6), autoConnect: false);
      await startDataStream(device: device, onPacket: handler);
      return true;
    } catch (e) {
      debugPrint('BleService.reconnectAndResume: $e');
      return false;
    }
  }
}

/// App-lifecycle guard: packets that arrive while the app is backgrounded (or in the first second after it
/// returns) are dropped, so they never count as compressions.
class _LifecycleGuard with WidgetsBindingObserver {
  _LifecycleGuard._() {
    WidgetsBinding.instance.addObserver(this);
  }

  static _LifecycleGuard? _instance;
  static void ensureStarted() => _instance ??= _LifecycleGuard._();

  static bool isAppActive = true;
  static DateTime? lastResumeTime;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isAppActive = true;
      lastResumeTime = DateTime.now();
    } else {
      isAppActive = false;
    }
  }
}

/// Whether the app is in the foreground (used by the game timer).
bool get isAppInForeground => _LifecycleGuard.isAppActive;
