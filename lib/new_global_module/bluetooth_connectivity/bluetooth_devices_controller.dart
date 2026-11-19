import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../AppManager/alert_dialogue.dart';
import '../../AppManager/progress_dialogue.dart';
import '../../App_Constant/app_constant.dart';
import '../../games/games_quiz/final_alert_page/routing_argument_data_modal.dart';
import '../routing/route_names.dart';
import '../services/base_controller.dart';

/// Scans for the CPR manikin, connects to it and owns the live BLE data stream.
///
/// The last data-stream parameters are remembered statically so the game can
/// [reconnectAndResume] after a dropped connection without the game screen
/// having to know anything about GATT services.
class BluetoothDevicesController extends BaseController with GetTickerProviderStateMixin, WidgetsBindingObserver {
  // ─── Subscriptions ─────────────────────────────────────────────────────────
  StreamSubscription? _bleDataSubscription;
  static StreamSubscription? _dataCleanupSubscription;
  StreamSubscription? _scanResultSubscription;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _isScanningSubscription;
  Timer? _opacityTimer;

  /// Used by the device list StreamBuilder.
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  // ─── Observables ───────────────────────────────────────────────────────────
  final RxBool isScanning = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool opacityAnimationVisible = false.obs;
  final RxDouble turns = 0.0.obs;

  // ─── Last stream parameters (used to resume after a disconnect) ────────────
  static BluetoothDevice? lastDevice;
  static String? lastServiceUuid;
  static String? lastCharacteristicsUuid;
  static void Function(dynamic data)? lastOnDataReceived;
  static bool? lastIsCPR;
  static bool? lastIsDisablePrint;

  /// True while the app itself disconnects the manikin (exit), so the
  /// "connection lost" dialog is not raised for a deliberate disconnect.
  static bool isIntentionalDisconnect = false;

  DateTime? _lastScanTime;
  late Rx<AnimationController> rippleController;

  static const List<String> _ctPrefixes = ['CT'];

  // ─── Init / close ──────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initializeController();
  }

  @override
  void onClose() {
    rippleController.value.dispose();
    cancelSubscriptions();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // ─── App lifecycle ─────────────────────────────────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      stopScan();
    } else if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  Future<void> _onAppResumed() async {
    if (!await areAllPermissionsGranted()) return;
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState == BluetoothAdapterState.on) startScanDevices();
  }

  Future<void> initializeController() async {
    _isScanningSubscription?.cancel();
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      isScanning.value = scanning;
      update();
    });
    rippleController = AnimationController(vsync: this, lowerBound: 0.5, duration: const Duration(seconds: 2)).obs;
    isLoading.value = false;
    rippleController.value.repeat();

    _opacityTimer?.cancel();
    _opacityTimer = Timer.periodic(const Duration(milliseconds: 800), (_) => opacityAnimationVisible.toggle());

    if (!(await FlutterBluePlus.isSupported)) {
      alertToast2('Bluetooth not supported by this device');
      return;
    }
    await FlutterBluePlus.setLogLevel(LogLevel.none, color: false);
    await requestPermissions();
    if (await areAllPermissionsGranted()) await startBluetoothHandling();
  }

  // ─── Permissions ───────────────────────────────────────────────────────────
  Future<void> requestPermissions() async {
    try {
      if (Platform.isAndroid && !(await areAllPermissionsGranted())) {
        final statuses = await [Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
        debugPrint('BT permissions: $statuses');
        if (await Permission.bluetoothScan.isPermanentlyDenied || await Permission.bluetoothConnect.isPermanentlyDenied || await Permission.location.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
        }
      }
    } catch (e) {
      debugPrint('Permission error: $e');
    }
  }

  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text('Bluetooth and Location permissions are permanently denied.\n\nPlease open App Settings and grant them.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> areAllPermissionsGranted() async {
    if (Platform.isIOS) return true;
    return await Permission.bluetoothScan.isGranted && await Permission.bluetoothConnect.isGranted && await Permission.location.isGranted;
  }

  // ─── Adapter on/off ────────────────────────────────────────────────────────
  /// The view's StreamBuilder<BluetoothAdapterState> reacts to the adapter
  /// turning on, so no navigation is needed here.
  Future<void> requestBluetoothOn() async {
    try {
      isLoading.value = true;
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      } else {
        await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
      }
    } catch (e) {
      debugPrint('requestBluetoothOn error: $e');
      alertToast2('Could not enable Bluetooth. Please turn it on manually.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startBluetoothHandling() async {
    _stateSubscription?.cancel();
    _stateSubscription = FlutterBluePlus.adapterState.listen(handleBluetoothState);
    final initialState = await FlutterBluePlus.adapterState.first;
    handleBluetoothState(initialState);
  }

  Future<void> handleBluetoothState(BluetoothAdapterState state) async {
    try {
      debugPrint('Bluetooth State: $state');
      if (state == BluetoothAdapterState.on) {
        // A manikin that is already connected is listed straight away, so no scan is needed.
        if (FlutterBluePlus.connectedDevices.isEmpty) startScanDevices();
      } else {
        stopScan();
      }
    } catch (e) {
      debugPrint('handleBluetoothState error: $e');
    }
  }

  // ─── Scan ──────────────────────────────────────────────────────────────────
  Future<void> startScanDevices() async {
    final now = DateTime.now();
    if (_lastScanTime != null && now.difference(_lastScanTime!).inMilliseconds < 1500) {
      debugPrint('Scan request throttled: clicked too fast');
      return;
    }
    _lastScanTime = now;
    turns.value += 4;
    update();

    await _scanResultSubscription?.cancel();
    _scanResultSubscription = null;

    try {
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
        await Future.delayed(const Duration(milliseconds: 600));
      }
      await FlutterBluePlus.startScan(
        withKeywords: _ctPrefixes,
        androidScanMode: AndroidScanMode.lowLatency,
        androidLegacy: true,
        continuousUpdates: true,
        continuousDivisor: 1,
        timeout: const Duration(seconds: 8),
        androidUsesFineLocation: false,
      );
    } on FlutterBluePlusException catch (e) {
      debugPrint('BLE scan error (${e.code}): ${e.description}');
      if (e.code == 2) alertToast2('Bluetooth was turned off. Please turn it back on.');
      update();
    } catch (e) {
      debugPrint('startScanDevices unexpected error: $e');
      await stopScan();
    }
  }

  Future<void> stopScan() async {
    try {
      if (FlutterBluePlus.isScanningNow) await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    } finally {
      update();
    }
  }

  // ─── Connect ───────────────────────────────────────────────────────────────
  /// Connects to [device] and opens the CPR game screen.
  Future<bool> connectToDevice(BluetoothDevice device) async {
    final bluetoothEnable = await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
    if (!bluetoothEnable) {
      ProgressDialogue().hide();
      alertToast2('Please turn on Bluetooth first');
      return false;
    }
    try {
      isIntentionalDisconnect = false;
      await FlutterBluePlus.stopScan();
      if (!device.isConnected) {
        await device.connect(timeout: const Duration(seconds: 6), autoConnect: false);
      }
      ProgressDialogue().hide();
      alertToast2('${device.advName} device connected');
      final args = RouteArguments(device: device, correctPoints: 0, incorrectPoints: 0, quizPoints: 0, jsonKey: '', pageId: AppConstant.adultCPRString);
      await Get.offNamed(RoutesNamed.cardiopulmonaryResuscitation, arguments: args);
      return true;
    } on TimeoutException {
      ProgressDialogue().hide();
      alertToast2('Connection timed out. Try again.');
      await _safeDisconnect(device);
      return false;
    } catch (e) {
      ProgressDialogue().hide();
      alertToast2('Could not connect. Try again.');
      await _safeDisconnect(device);
      return false;
    }
  }

  Future<void> _safeDisconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (_) {}
  }

  // ─── Data stream ───────────────────────────────────────────────────────────
  Future<void> connectedDeviceBleData({
    required BluetoothDevice device,
    required String serviceUuid,
    required String characteristicsUuid,
    required void Function(dynamic data) onDataReceived,
    bool isCPR = false,
    bool? isDisablePrint = false,
  }) async {
    isIntentionalDisconnect = false;
    lastDevice = device;
    lastServiceUuid = serviceUuid;
    lastCharacteristicsUuid = characteristicsUuid;
    lastOnDataReceived = onDataReceived;
    lastIsCPR = isCPR;
    lastIsDisablePrint = isDisablePrint;

    BluetoothLifecycleGuard(); // initialise the global lifecycle observer
    try {
      final List<BluetoothService> services = await device.discoverServices();
      for (final service in services) {
        if (!service.serviceUuid.toString().toUpperCase().contains(serviceUuid.toUpperCase())) continue;
        for (final char in service.characteristics) {
          if (!char.uuid.toString().toUpperCase().contains(characteristicsUuid.toUpperCase())) continue;

          await char.setNotifyValue(true);
          await _bleDataSubscription?.cancel();
          // onValueReceived: no cached replay, fires on real hardware events only
          _bleDataSubscription = char.onValueReceived.listen(
            (data) {
              if (!BluetoothLifecycleGuard.isAppActive) return;
              if (BluetoothLifecycleGuard.lastResumeTime != null && DateTime.now().difference(BluetoothLifecycleGuard.lastResumeTime!).inMilliseconds < 1000) {
                return; // buffer flush right after resume
              }
              if (data.isEmpty) return;
              try {
                if (isCPR) {
                  onDataReceived(ascii.decode(data, allowInvalid: true).split(','));
                } else {
                  onDataReceived(ascii.decode(data, allowInvalid: true));
                }
              } catch (e) {
                debugPrint('BLE decode error: $e');
              }
            },
            onError: (e) => debugPrint('BLE data stream error: $e'),
            cancelOnError: false,
          );
          break;
        }
      }

      // Data-stream cleanup only. The "connection lost" dialog is raised by
      // BluetoothConnectionWatcher (one per game screen).
      await _dataCleanupSubscription?.cancel();
      _dataCleanupSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _bleDataSubscription?.cancel();
          _bleDataSubscription = null;
          debugPrint('Device disconnected. Data subscription canceled.');
        }
      });
    } catch (e) {
      debugPrint('connectedDeviceBleData error: $e');
    }
  }

  /// Reconnects to the last manikin and re-attaches the same data handler.
  Future<bool> reconnectAndResume() async {
    if (lastDevice == null || lastServiceUuid == null || lastCharacteristicsUuid == null || lastOnDataReceived == null) {
      debugPrint('reconnectAndResume: missing connection parameters.');
      return false;
    }
    try {
      if (!lastDevice!.isConnected) {
        await lastDevice!.connect(timeout: const Duration(seconds: 6), autoConnect: false);
      }
      await connectedDeviceBleData(
        device: lastDevice!,
        serviceUuid: lastServiceUuid!,
        characteristicsUuid: lastCharacteristicsUuid!,
        onDataReceived: lastOnDataReceived!,
        isCPR: lastIsCPR ?? false,
        isDisablePrint: lastIsDisablePrint ?? false,
      );
      return true;
    } catch (e) {
      debugPrint('reconnectAndResume error: $e');
      return false;
    }
  }

  void cancelSubscriptions() {
    try {
      _stateSubscription?.cancel();
      _stateSubscription = null;
      _scanResultSubscription?.cancel();
      _scanResultSubscription = null;
      _bleDataSubscription?.cancel();
      _bleDataSubscription = null;
      _opacityTimer?.cancel();
      _opacityTimer = null;
      _isScanningSubscription?.cancel();
      _isScanningSubscription = null;
    } catch (e) {
      debugPrint('Error in cancelSubscriptions: $e');
    }
  }

  /// Disconnects the manikin on purpose (game exit).
  Future<void> disConnectAndDisposeSelectedDevice(BluetoothDevice device) async {
    isIntentionalDisconnect = true;
    try {
      if (device.isConnected) {
        try {
          await device.clearGattCache();
        } catch (e) {
          debugPrint('clearGattCache failed: $e');
        }
        await device.disconnect();
        alertToast2('${device.advName} device Disconnected');
      }
    } catch (e) {
      debugPrint('Error in disConnectAndDisposeSelectedDevice: $e');
    } finally {
      await _dataCleanupSubscription?.cancel();
      _dataCleanupSubscription = null;
      await _bleDataSubscription?.cancel();
      _bleDataSubscription = null;
      lastOnDataReceived = null;
      update();
    }
  }
}

/// Global app-lifecycle guard: BLE packets that arrive while the app is in the
/// background (or in the first second after resuming) are dropped so they never
/// count as compressions.
class BluetoothLifecycleGuard with WidgetsBindingObserver {
  static final BluetoothLifecycleGuard _instance = BluetoothLifecycleGuard._internal();

  factory BluetoothLifecycleGuard() => _instance;

  BluetoothLifecycleGuard._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

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
