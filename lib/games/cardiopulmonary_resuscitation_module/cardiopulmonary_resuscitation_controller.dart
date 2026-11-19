import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../App_Constant/app_constant.dart';
import '../../new_global_module/bluetooth_connectivity/bluetooth_devices_controller.dart';
import '../../new_global_module/services/base_controller.dart';
import '../common_widgets/backalert_bottomsheet.dart';
import '../common_widgets/common_functions/bluetooth_connection_lost.dart';
import '../common_widgets/game_export_class.dart';
import '../games_quiz/final_alert_page/routing_argument_data_modal.dart';
import 'SerivicesVr/event_sender_service.dart';
import 'SerivicesVr/network_monitor_service.dart';
import 'SerivicesVr/result_dialog_widget.dart';
import 'cardiopulmonary_resuscitation_modal.dart';
import 'cpr_widget_and_data_modals/bluetooth_response_data_modal.dart';
import 'cpr_widget_and_data_modals/cpr_data_modal_for_ui.dart';

/// CPR game: reads the manikin over BLE, counts compressions / air blows, streams every event to the VR server
/// and shows the result when the 60 s are over.
class CardiopulmonaryResuscitationController extends BaseController with WidgetsBindingObserver, StateMixin<CPRConfig> {
  static const String _serviceUuid = "C201";
  static const String _characteristicUuid = "483E";

  final NetworkMonitor monitor = NetworkMonitor();
  final RxStatus status = RxStatus.empty();
  final CPRApiModal _modal = CPRApiModal();
  final EventSender eventSender = EventSender();
  late RouteArguments args;

  /// timer
  Timer? _mainTimer, _airBlowTimer;
  static const _initialSecond = 60;
  RxInt second = _initialSecond.obs;

  final RxBool _isIncrement = true.obs;
  final RxBool _isTimerActive = false.obs, _isScoreDialogOpen = false.obs, isCPRWithAirBlow = true.obs;

  /// CPR counters
  RxInt totalCorrectCount = 0.obs, totalInCorrectCount = 0.obs, totalCPRPoints = 0.obs;
  final RxInt totalCompressionOfCpr = 0.obs, totalNumberOfAttempt = 1.obs;
  final RxInt _maxCompression = 0.obs;

  /// Bluetooth response
  List bluetoothResponse = <BluetoothResponseDataModal>[].obs;
  final bluetoothResponseDataModal = BluetoothResponseDataModal(cprValue: 0, leftCompression: 1, rightCompression: 1, airBlowValue: 1.13).obs;

  /// Single shared reader of the manikin's connection state (app bar icon, lost dialog, timer pause/resume).
  BluetoothConnectionWatcher? _connectionWatcher;
  ValueNotifier<bool>? get isDeviceConnected => _connectionWatcher?.isConnected;
  bool _wasTimerRunning = false;
  bool _pausedByLifecycle = false;

  @override
  void onInit() {
    super.onInit();
    monitor.startMonitoring();
    if (Get.arguments != null) args = Get.arguments;
    everAll([totalCorrectCount, totalInCorrectCount], (_) => totalCompressionOfCpr.value = totalCorrectCount.value + totalInCorrectCount.value);
    WidgetsBinding.instance.addPostFrameCallback((_) => initialize());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Continue only if the countdown was running when the app was sent to the background.
      if (_pausedByLifecycle) {
        _pausedByLifecycle = false;
        _startTimer();
      }
    } else if (_mainTimer?.isActive ?? false) {
      _pausedByLifecycle = true;
      _stopTimer();
    }
  }

  @override
  void dispose() {
    cancelSubscriptions();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onClose() {
    cancelSubscriptions();
    super.onClose();
  }

  static final Map<String, dynamic> cprConfigJson = {
    AppConstant.adultCPRString: {
      "image": AppConstant.adultCPRImage,
      "gap": 0.22,

      ///leftRedDot
      "leftRedDotTop": 0.65,
      "leftRedDotRight": 0.0,
      "leftRedDotLeft": 0.25,

      ///rightRedDot
      "rightRedDotTop": 0.65,
      "rightRedDotRight": 0.25,
      "rightRedDotLeft": 0.0,

      ///centerRedAndGreenRedDot
      "centerGreenRedDotTop": 0.62,
      "centerGreenRedDotRight": 1.0,
      "centerGreenRedDotLeft": 0.0,
    },
    AppConstant.childCPRString: {
      "image": AppConstant.childCPRImage,
      "gap": 0.05,

      ///leftRedDot
      "leftRedDotTop": 0.25,
      "leftRedDotRight": 0.0,
      "leftRedDotLeft": 0.1,

      ///rightRedDot
      "rightRedDotTop": 0.25,
      "rightRedDotRight": 0.1,
      "rightRedDotLeft": 0.0,

      ///centerRedAndGreenRedDot
      "centerGreenRedDotTop": 0.25,
      "centerGreenRedDotRight": 0.2,
      "centerGreenRedDotLeft": 0.0,
    },
    AppConstant.neonatalCPRString: {
      "image": AppConstant.neonatalCPRImage,
      "gap": 0.05,

      ///leftRedDot
      "leftRedDotTop": 0.33,
      "leftRedDotRight": 0.0,
      "leftRedDotLeft": 0.1,

      ///rightRedDot
      "rightRedDotTop": 0.33,
      "rightRedDotRight": 0.1,
      "rightRedDotLeft": 0.0,

      ///centerRedAndGreenRedDot
      "centerGreenRedDotTop": 0.34,
      "centerGreenRedDotRight": 0.2,
      "centerGreenRedDotLeft": 0.0,
    },
  };

  static CPRConfig getCPRConfig(String pageId) => CPRConfig.fromJson(cprConfigJson[pageId] ?? {});

  final Rx<CPRConfig?> uiConfig = Rx<CPRConfig?>(null);

  /// Method to load CPR config
  void loadUIConfig(String pageId) {
    try {
      uiConfig.value = getCPRConfig(pageId);
    } catch (e) {
      change(null, status: RxStatus.error('Failed to load CPR configuration'));
    }
  }

  /// Cleanup and cancel subscriptions
  void cancelSubscriptions() {
    for (var w in _workers) {
      w.dispose();
    }
    _workers.clear();
    _connectionWatcher?.isConnected.removeListener(_onConnectionChanged);
    _connectionWatcher?.release();
    _connectionWatcher = null;
    _stopTimer();
    _airBlowTimer?.cancel();
    _airBlowTimer = null;
    monitor.stopMonitoring();
  }

  /// Init
  Future<void> initialize() async {
    try {
      loadUIConfig(args.pageId.toString());
      _listenConnectionState();
      everWhenDialogOpen();
      await initDataFetching();
    } catch (e) {
      debugPrint('Initialization error: $e');
      change(null, status: RxStatus.error('Failed to initialize'));
    } finally {
      change(uiConfig.value, status: RxStatus.success());
    }
  }

  // ─── Connection handling ───────────────────────────────────────────────────

  void _listenConnectionState() {
    _connectionWatcher?.isConnected.removeListener(_onConnectionChanged);
    _connectionWatcher?.release();
    _connectionWatcher = BluetoothConnectionWatcher.acquire(args.device)..isConnected.addListener(_onConnectionChanged);
    update();
  }

  /// Pause the countdown while the manikin is disconnected and continue it once the connection is back.
  void _onConnectionChanged() {
    if (isClosed) return;
    if (_connectionWatcher?.isConnected.value == false) {
      _wasTimerRunning = _mainTimer?.isActive ?? false;
      _stopTimer();
    } else if (_wasTimerRunning) {
      _wasTimerRunning = false;
      _startTimer();
    }
  }

  // ─── Timer ─────────────────────────────────────────────────────────────────

  void _startTimer() {
    if (isClosed || !BluetoothLifecycleGuard.isAppActive || _isScoreDialogOpen.isTrue) return;
    const oneSecond = Duration(seconds: 1);
    if (second.value == 0) {
      _stopTimer();
      return;
    }
    if (_mainTimer != null && _mainTimer!.isActive) return;
    _mainTimer = Timer.periodic(oneSecond, (timer) async {
      if (isClosed) {
        _stopTimer();
        return;
      }
      if (_isScoreDialogOpen.isFalse && (second.value <= 0 || totalCompressionOfCpr.value > 120)) {
        showScoreDialog();
        if (!isClosed) update();
        _stopTimer();
        return;
      }
      if (_mainTimer != null && _mainTimer!.isActive && second.value > 0 && !(Get.isDialogOpen ?? false)) {
        second.value--;
      }
    });
  }

  void _stopTimer() {
    if (_mainTimer != null && _mainTimer!.isActive) {
      _mainTimer!.cancel();
    }
    _mainTimer = null;
  }

  /// Reset timer and counters
  void resetTimer() {
    second.value = _initialSecond;
    totalCorrectCount.value = 0;
    totalInCorrectCount.value = 0;
    totalNumberOfAttempt.value = 1;
    _isTimerActive.value = false;
  }

  int? _lastAirBlowValue;
  final List<Worker> _workers = [];

  void everWhenDialogOpen() {
    _workers.add(ever<int>(totalCompressionOfCpr, (value) async {
      if (value == 30 || value == 60 || value == 90) {
        _stopTimer();
        final airBlow = bluetoothResponseDataModal.value.airBlowValue;
        await _modal.buildAirBlowDialog(isCPRWithAirBlow.value, second: second, airBlowValue: airBlow);
        _startTimer();
      }
    }));
    _workers.add(ever<int>(_modal.correctAirBlowCounter, (val) async {
      if (val == 0) _lastAirBlowValue = null;
      if ((val == 1 || val == 2) && val != _lastAirBlowValue) {
        _lastAirBlowValue = val;
        cprDetailsListener(1);
      }
    }));
  }

  // ─── Bluetooth data ────────────────────────────────────────────────────────

  /// Initialize Bluetooth data fetching
  Future<void> initDataFetching() async {
    try {
      resetTimer();
      if (!args.device.isConnected) await args.device.connect();
      await BluetoothDevicesController().connectedDeviceBleData(
          device: args.device,
          serviceUuid: _serviceUuid,
          characteristicsUuid: _characteristicUuid,
          isCPR: true,
          isDisablePrint: true,
          onDataReceived: (data) async {
            try {
              if (data == null || data.isEmpty || data.length < 4 || second.value == 0 || _isScoreDialogOpen.isTrue) {
                // nothing to do: bad packet, or the game is already over
              } else if (totalCompressionOfCpr.value >= 120) {
                second.value = 0;
              } else {
                bluetoothResponse = data;
                await _handleReceivedData();
              }
              update();
            } catch (e) {
              debugPrint('Bluetooth_data_exceptions$e');
            }
          });
    } catch (e) {
      debugPrint('Exception :$e');
    }
  }

  /// Handle received Bluetooth data
  Future<void> _handleReceivedData() async {
    try {
      bluetoothResponseDataModal.update((modal) {
        if (_isScoreDialogOpen.isFalse) {
          if (Get.isDialogOpen == false) {
            modal?.cprValue = int.tryParse(bluetoothResponse[0].toString()) ?? 0;
            modal?.rightCompression = int.tryParse(bluetoothResponse[1].toString()) ?? 1;
            modal?.leftCompression = int.tryParse(bluetoothResponse[2].toString()) ?? 1;
            modal?.airBlowValue = double.tryParse(bluetoothResponse[3].toString()) ?? 1.13;
          } else {
            modal?.airBlowValue = double.tryParse(bluetoothResponse[3].toString()) ?? 1.13;
          }
        }
      });

      if (Get.isDialogOpen == false && bluetoothResponseDataModal.value.leftCompression == AppConstant.cprIncorrectA ||
          bluetoothResponseDataModal.value.rightCompression == AppConstant.cprIncorrectB) {
        _inCorrectCount();
      } else if (bluetoothResponseDataModal.value.airBlowValue > AppConstant.cprAirBlowMaximumValue && _isIncrement.value) {
        if (_modal.correctAirBlowCounter.value < 2) {
          _isIncrement.value = false;
          _modal.correctAirBlowCounter.value++;
          _delayForNextCountOfCPR(milliseconds: 800);
        }
      } else {
        _handleCompression();
      }
    } catch (e) {
      debugPrint('_handleReceivedData_Exception :$e');
    }
  }

  /// Increment incorrect count
  Future<void> _inCorrectCount() async {
    try {
      if (_isIncrement.isTrue) {
        _isIncrement.value = false;
        _startTimer();
        totalInCorrectCount.value++;
        _delayForNextCountOfCPR(milliseconds: 600);
      }
    } catch (e) {
      debugPrint('_inCorrectCount_Exception: $e');
    }
  }

  /// Handle compression logic based on received data
  Future<void> _handleCompression() async {
    try {
      final compressionValue = bluetoothResponseDataModal.value.cprValue;
      if (_isIncrement.value) {
        _maxCompression.value = max(_maxCompression.value, compressionValue);
      }
      if (compressionValue >= 0 && compressionValue <= 10) {
        if (compressionValue > 0) _startTimer();
        if (_maxCompression.value >= 8 && compressionValue < 4 && _isIncrement.value) {
          _handleCorrectAndIncorrectCount(true, _maxCompression.value);
        } else if (_maxCompression.value < 8 && _maxCompression.value > 2 && compressionValue < 2 && _isIncrement.value) {
          _handleCorrectAndIncorrectCount(false, _maxCompression.value);
        }
      }
    } catch (e) {
      debugPrint('_handleCompression_Exception :$e');
    }
  }

  Future<void> _handleCorrectAndIncorrectCount(bool isCorrect, int compressionValue) async {
    isCorrect ? totalCorrectCount.value++ : totalInCorrectCount.value++;
    _maxCompression.value = 0;
    _isIncrement.value = false;
    _delayForNextCountOfCPR();
    cprDetailsListener(0, isCorrect: isCorrect, compressionValue: compressionValue);
  }

  /// Delay to prevent double-counting
  void _delayForNextCountOfCPR({int milliseconds = 10}) => milliseconds.milliseconds.delay(() => _isIncrement.value = true);

  // ─── Result / retry / exit ─────────────────────────────────────────────────

  /// Start a fresh attempt from the result dialog.
  void _handleRetryButton() {
    totalNumberOfAttempt.value++;
    second.value = _initialSecond;
    totalCPRPoints.value = 0;
    totalCorrectCount.value = 0;
    totalInCorrectCount.value = 0;
    _maxCompression.value = 0;
    _isScoreDialogOpen.value = false;
    BackAlertBottomSheet.stopNotifications(serviceUuid: _serviceUuid, charUuid: _characteristicUuid, device: args.device, isListen: true);
    Get.back();
  }

  /// Display the result dialog and send the final result to the VR server.
  Future<void> showScoreDialog() async {
    try {
      if (isClosed) return;
      _isScoreDialogOpen.value = true;
      _stopTimer();
      cprDetailsListener(EventSender.finalEventType);
      totalCPRPoints.value = (6 - totalNumberOfAttempt.value).clamp(1, 5);
      final bool unSuccessFullAttempt = totalCorrectCount.value <= 100;
      BackAlertBottomSheet.stopNotifications(serviceUuid: _serviceUuid, charUuid: _characteristicUuid, device: args.device);
      update();
      Get.dialog(
        barrierDismissible: false,
        ResultDialog(
          isCorrect: !unSuccessFullAttempt,
          total: totalCompressionOfCpr.value,
          correct: totalCorrectCount.value,
          incorrect: totalInCorrectCount.value,
          onRetry: _handleRetryButton,
          onExit: exitingGameBottomSheet,
        ),
      );
    } catch (e) {
      debugPrint("Error while scoreDialog : $e");
    }
  }

  /// Confirmation sheet, then disconnect the manikin and go back to the dashboard.
  Future<void> exitingGameBottomSheet() async {
    try {
      BackAlertBottomSheet.exit(
        device: args.device,
        beforeExit: () async {
          _stopTimer();
          await BackAlertBottomSheet.stopNotifications(serviceUuid: _serviceUuid, charUuid: _characteristicUuid, device: args.device);
          eventSender.clearLiveEvents();
        },
      );
    } catch (e) {
      debugPrint("Error while exit : $e");
    }
  }

  // ─── VR payloads ───────────────────────────────────────────────────────────

  /// CPR payload (eventType = 0)
  Map<String, dynamic> _buildCprPayload(int compressionValue, int correctFlag) => {
        "eventType": 0,
        "pressure": compressionValue,
        "count": totalCorrectCount.value + totalInCorrectCount.value,
        "timeLeft": second.value,
        "isCorrect": correctFlag,
        "correctCompression": 0,
        "inCorrectCompression": 0
      };

  /// Air Bag payload (eventType = 1)
  Map<String, dynamic> _buildAirPayload() =>
      {"eventType": 1, "pressure": 0, "count": _modal.correctAirBlowCounter.value, "timeLeft": _modal.secondAirBlow.value, "isCorrect": 0, "correctCompression": 0, "inCorrectCompression": 0};

  /// Final Result payload (eventType = 2)
  Map<String, dynamic> _buildFinalPayload() =>
      {"eventType": 2, "pressure": 0, "count": 0, "timeLeft": 0, "isCorrect": 0, "correctCompression": totalCorrectCount.value, "inCorrectCompression": totalInCorrectCount.value};

  /// Queue an event for the VR server: 0 = compression, 1 = air blow, 2 = final result.
  void cprDetailsListener(int eventType, {bool isCorrect = false, int compressionValue = 0}) {
    final Map<String, dynamic> body;
    if (eventType == 0) {
      body = _buildCprPayload(compressionValue, isCorrect ? 1 : 0);
    } else if (eventType == 1) {
      body = _buildAirPayload();
    } else {
      body = _buildFinalPayload();
    }
    eventSender.sendEvent(body);
  }
}
