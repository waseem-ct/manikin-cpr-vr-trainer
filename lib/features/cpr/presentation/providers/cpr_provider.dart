import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/snack_bar_service.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/connection_lost_dialog.dart';
import '../../../bluetooth/data/services/ble_service.dart';
import '../../data/repositories/cpr_settings_repository.dart';
import '../../data/services/network_monitor_service.dart';
import '../../data/services/vr_event_service.dart';
import '../../domain/entities/cpr_event.dart';
import '../../domain/entities/cpr_layout.dart';
import '../../domain/entities/cpr_sensor_data.dart';
import '../../domain/entities/cpr_settings.dart';
import '../widgets/air_blow_dialog.dart';
import '../widgets/result_dialog.dart';

/// One CPR session.
///
/// Reads the manikin over BLE, counts compressions and rescue breaths, runs the 60 s countdown, streams every
/// event to the VR server and shows the result at the end. It also survives a dropped Bluetooth connection:
/// the countdown pauses, a dialog offers Exit / Retry, and the session resumes when the manikin is back.
class CprProvider extends ChangeNotifier with WidgetsBindingObserver {
  CprProvider(this.device, this._ble, this._vr, this._monitor, this._settingsRepository, this._navigation, this._dialogs, this._snackBar)
      : _withAirBlow = _settingsRepository.load().withAirBlow,
        settings = _settingsRepository.load(),
        isDeviceConnected = device.isConnected,
        _wasConnected = device.isConnected;

  // ── Game rules ─────────────────────────────────────────────────────────────
  static const int sessionSeconds = 60;
  static const int airBlowWindowSeconds = 20;
  static const int successCorrectCount = 100;
  static const int maxCompressions = 120;
  static const Set<int> airBlowAfterCounts = {30, 60, 90};
  static const int correctPressure = 8; // a press must reach this to count as correct
  static const int minPressure = 3; // a shallower press than this is ignored

  final BluetoothDevice device;
  final CprSettings settings;

  final CprSettingsRepository _settingsRepository;
  final BleService _ble;
  final VrEventService _vr;
  final NetworkMonitorService _monitor;
  final NavigationService _navigation;
  final DialogService _dialogs;
  final SnackBarService _snackBar;

  // ── Observable state ───────────────────────────────────────────────────────
  int _second = sessionSeconds;
  int _attempt = 1;
  int _correct = 0;
  int _incorrect = 0;
  CprSensorData _sensor = const CprSensorData();
  bool _isReady = false;
  bool isDeviceConnected;
  bool _withAirBlow;

  /// Rescue breaths counted in the open air-blow dialog (0-2) and the live air-blow sensor value.
  final ValueNotifier<int> airBlowCount = ValueNotifier(0);
  final ValueNotifier<double> airBlowValue = ValueNotifier(1.13);

  int get second => _second;
  int get attempt => _attempt;
  int get correct => _correct;
  int get incorrect => _incorrect;
  int get total => _correct + _incorrect;
  CprSensorData get sensor => _sensor;
  bool get isReady => _isReady;
  bool get withAirBlow => _withAirBlow;
  CprLayout get layout => settings.type.layout;
  Stream<int> get pingStream => _monitor.pingStream;

  // ── Internals ──────────────────────────────────────────────────────────────
  Timer? _timer;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  int _maxPressure = 0;
  bool _canCount = true; // short lock after each count, so one press is never counted twice
  bool _isScoreOpen = false;
  bool _isAirBlowOpen = false;
  bool _isLostOpen = false;
  bool _isResuming = false;
  bool _wasConnected;
  bool _wasTimerRunning = false;
  bool _pausedByLifecycle = false;
  bool _isDisposed = false;

  bool get _isAnyDialogOpen => _isAirBlowOpen || _isLostOpen || _isScoreOpen;

  /// "With Air Blow" from the game menu. Takes effect at the next rescue-breath step and is remembered.
  void setWithAirBlow(bool value) {
    if (value == _withAirBlow) return;
    _withAirBlow = value;
    _settingsRepository.save(CprSettings(type: settings.type, withAirBlow: value));
    _notify();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    _monitor.start();
    _connectionSubscription = device.connectionState.listen(_onConnectionState);
    try {
      if (!device.isConnected) await device.connect();
      await _ble.startDataStream(device: device, onPacket: _onPacket);
    } catch (e) {
      debugPrint('CprProvider.start: $e');
    }
    _isReady = true;
    _notify();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Continue only if the countdown was running when the app went to the background.
      if (_pausedByLifecycle) {
        _pausedByLifecycle = false;
        _startTimer();
      }
    } else if (_timer?.isActive ?? false) {
      _pausedByLifecycle = true;
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _connectionSubscription?.cancel();
    _monitor.dispose();
    airBlowCount.dispose();
    airBlowValue.dispose();
    super.dispose();
  }

  // ── Timer ──────────────────────────────────────────────────────────────────
  void _startTimer() {
    if (_isDisposed || !isAppInForeground || _isScoreOpen) return;
    if (_second == 0) {
      _stopTimer();
      return;
    }
    if (_timer?.isActive ?? false) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isDisposed) {
        _stopTimer();
        return;
      }
      if (!_isScoreOpen && (_second <= 0 || total > maxCompressions)) {
        _showResult();
        _stopTimer();
        return;
      }
      if (_second > 0 && !_isAnyDialogOpen) {
        _second--;
        _notify();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ── BLE data ───────────────────────────────────────────────────────────────
  void _onPacket(List<String> packet) {
    if (_isDisposed) return;
    final data = CprSensorData.fromPacket(packet);
    if (data == null || _second == 0 || _isScoreOpen) return; // bad packet, or the game is over
    if (total >= maxCompressions) {
      _second = 0; // the timer tick then shows the result
      _notify();
      return;
    }
    airBlowValue.value = data.airBlow;

    if (_isAnyDialogOpen) {
      // A dialog hides the chest: only rescue breaths matter now.
      _sensor = _sensor.withAirBlowFrom(data);
      if (data.isBreath) _countBreath();
    } else {
      _sensor = data;
      if (data.isLeftIncorrect || data.isRightIncorrect) {
        _countIncorrectSide();
      } else if (data.isBreath) {
        _countBreath();
      } else {
        _handlePressure();
      }
    }
    _notify();
  }

  /// A press on the wrong side of the chest.
  void _countIncorrectSide() {
    if (!_canCount) return;
    _lockCounting(const Duration(milliseconds: 600));
    _startTimer();
    _incorrect++;
    _afterCountChanged();
  }

  /// Compression depth logic: remember the deepest press, count it when the chest is released.
  void _handlePressure() {
    final pressure = _sensor.pressure;
    if (_canCount) _maxPressure = max(_maxPressure, pressure);
    if (pressure < 0 || pressure > 10) return;
    if (pressure > 0) _startTimer();
    if (_maxPressure >= correctPressure && pressure < 4 && _canCount) {
      _countCompression(isCorrect: true);
    } else if (_maxPressure < correctPressure && _maxPressure >= minPressure && pressure < 2 && _canCount) {
      _countCompression(isCorrect: false);
    }
  }

  void _countCompression({required bool isCorrect}) {
    final pressure = _maxPressure;
    isCorrect ? _correct++ : _incorrect++;
    _maxPressure = 0;
    _lockCounting(const Duration(milliseconds: 10));
    _vr.send(CprEvent.compression(pressure: pressure, count: total, timeLeft: _second, isCorrect: isCorrect));
    _afterCountChanged();
  }

  /// A rescue breath (only counted while the air-blow dialog is open and measuring).
  void _countBreath() {
    if (!_canCount || !_isAirBlowOpen || !_withAirBlow || airBlowCount.value >= 2) return;
    _lockCounting(const Duration(milliseconds: 800));
    airBlowCount.value++;
    _vr.send(CprEvent.airBlow(count: airBlowCount.value, timeLeft: airBlowWindowSeconds));
    if (airBlowCount.value == 2) {
      // Give the success animation a second, then close the dialog.
      Future.delayed(const Duration(seconds: 1), () {
        if (_isAirBlowOpen && !_isDisposed) _dialogs.dismiss();
      });
    }
  }

  void _lockCounting(Duration duration) {
    _canCount = false;
    Future.delayed(duration, () => _canCount = true);
  }

  void _afterCountChanged() {
    _notify();
    if (airBlowAfterCounts.contains(total)) _openAirBlowDialog();
  }

  // ── Air blow (rescue breaths) ──────────────────────────────────────────────
  Future<void> _openAirBlowDialog() async {
    _stopTimer();
    if (!_isAirBlowOpen && _second > 1) {
      _isAirBlowOpen = true;
      airBlowCount.value = 0;
      await _dialogs.show<void>((_) => AirBlowDialog(withAirBlow: _withAirBlow, breathCount: airBlowCount, airBlowValue: airBlowValue));
      _isAirBlowOpen = false;
    }
    _startTimer();
  }

  // ── Result / retry / exit ──────────────────────────────────────────────────
  Future<void> _showResult() async {
    if (_isDisposed || _isScoreOpen) return;
    _isScoreOpen = true;
    _stopTimer();
    _vr.send(CprEvent.finalResult(correct: _correct, incorrect: _incorrect));
    _ble.setNotifications(device, enabled: false);
    _notify();
    await _dialogs.show<void>((_) => ResultDialog(isSuccess: _correct > successCorrectCount, total: total, correct: _correct, incorrect: _incorrect, onRetry: _retry, onExit: confirmExit));
  }

  /// Starts a fresh attempt from the result dialog.
  void _retry() {
    _attempt++;
    _second = sessionSeconds;
    _correct = 0;
    _incorrect = 0;
    _maxPressure = 0;
    _isScoreOpen = false;
    _ble.setNotifications(device, enabled: true);
    _dialogs.dismiss();
    _notify();
  }

  /// Back button / exit: confirm first.
  void confirmExit() {
    _dialogs.showSheet<void>((_) => ConfirmSheet(message: AppConstants.exitMessage, confirmLabel: 'Exit', onConfirm: _exit));
  }

  Future<void> _exit() async {
    _dialogs.showProgress('Exiting');
    try {
      _stopTimer();
      await _ble.setNotifications(device, enabled: false);
      _vr.clearLiveEvents();
      await _ble.disconnect(device).timeout(const Duration(seconds: 4), onTimeout: () => debugPrint('Disconnect timed out, continuing'));
    } catch (e) {
      debugPrint('CprProvider._exit: $e');
    }
    await _dialogs.hideProgress();
    _dialogs.dismiss(); // the confirm sheet
    _closeOverlaysAndGoHome();
  }

  void _closeOverlaysAndGoHome() {
    if (_isScoreOpen) {
      _isScoreOpen = false;
      _dialogs.dismiss(); // the result dialog
    }
    Future.microtask(_navigation.goToHome);
  }

  // ── Connection loss / resume ───────────────────────────────────────────────
  void _onConnectionState(BluetoothConnectionState state) {
    final connected = state == BluetoothConnectionState.connected;
    isDeviceConnected = connected;
    _notify();

    if (connected) {
      _wasConnected = true;
      if (_isLostOpen && !_isResuming) {
        _resume().then((ok) {
          if (ok) _closeLostDialog();
        });
      }
      if (_wasTimerRunning) {
        _wasTimerRunning = false;
        _startTimer();
      }
    } else if (_wasConnected) {
      // Only connected -> disconnected is a "lost connection" (not our own disconnect on exit).
      _wasConnected = false;
      _wasTimerRunning = _timer?.isActive ?? false;
      _stopTimer();
      if (!_ble.isIntentionalDisconnect) _showLostDialog();
    }
  }

  void _showLostDialog() {
    if (_isLostOpen) return;
    _isLostOpen = true;
    _dialogs.show<void>((_) => ConnectionLostDialog(onExit: _exitFromLostDialog, onRetry: _retryFromLostDialog)).whenComplete(() => _isLostOpen = false);
  }

  void _closeLostDialog() {
    if (!_isLostOpen) return;
    _isLostOpen = false;
    _dialogs.dismiss();
  }

  Future<bool> _resume() async {
    if (_isResuming) return false;
    _isResuming = true;
    try {
      return await _ble.reconnectAndResume();
    } finally {
      _isResuming = false;
    }
  }

  Future<void> _retryFromLostDialog() async {
    if (_isResuming) return;
    _dialogs.showProgress('Reconnecting...');
    final ok = await _resume();
    await _dialogs.hideProgress(); // hide the progress dialog first, so closing the lost dialog pops the right route
    if (ok) _closeLostDialog();
    _snackBar.show(ok ? 'Reconnected successfully!' : 'Reconnection failed. Try again.');
  }

  Future<void> _exitFromLostDialog() async {
    _closeLostDialog();
    _stopTimer();
    _vr.clearLiveEvents();
    await _ble.disconnect(device);
    _closeOverlaysAndGoHome();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }
}
