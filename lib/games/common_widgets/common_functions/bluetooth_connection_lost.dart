import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../AppManager/alert_dialogue.dart';
import '../../../AppManager/bluetooth_lostConnnection_alert.dart';
import '../../../AppManager/progress_dialogue.dart';
import '../../../new_global_module/bluetooth_connectivity/bluetooth_devices_controller.dart';
import '../../../new_global_module/routing/route_names.dart';
import '../game_export_class.dart';

/// The single reader of a manikin's connection state, shared by everything on the game screen (app-bar indicator,
/// "connection lost" dialog, game timers). There is exactly one stream subscription per device no matter how many
/// widgets use it: call [acquire] to get it and [release] when done.
class BluetoothConnectionWatcher {
  static final Map<String, BluetoothConnectionWatcher> _instances = {};

  /// Returns the shared watcher for [device], starting it on first use.
  static BluetoothConnectionWatcher acquire(BluetoothDevice device) {
    final watcher = _instances.putIfAbsent(device.remoteId.str, () => BluetoothConnectionWatcher._(device).._start());
    watcher._refCount++;
    return watcher;
  }

  final BluetoothDevice device;

  /// Live connection state: drives the app-bar "Connected / Disconnected" icon.
  final ValueNotifier<bool> isConnected;

  StreamSubscription<BluetoothConnectionState>? _subscription;
  int _refCount = 0;
  bool _wasConnected;

  BluetoothConnectionWatcher._(this.device)
      : isConnected = ValueNotifier(device.isConnected),
        _wasConnected = device.isConnected;

  void _start() {
    _subscription = device.connectionState.listen((state) {
      final connected = state == BluetoothConnectionState.connected;
      isConnected.value = connected;
      if (connected) {
        _wasConnected = true;
        BluetoothConnectionLostFunc.onDeviceConnected(device);
      } else if (_wasConnected) {
        // Only a connected -> disconnected transition is a "lost connection". This ignores the initial
        // "disconnected" state of a device that never connected, and our own intentional disconnect on exit.
        _wasConnected = false;
        if (!BluetoothDevicesController.isIntentionalDisconnect) {
          BluetoothConnectionLostFunc.bluetoothLostConnectionDialog(device);
        }
      }
    });
  }

  /// Release the watcher obtained with [acquire]; the stream is closed when the last user releases it.
  void release() {
    if (--_refCount > 0) return;
    _subscription?.cancel();
    _subscription = null;
    isConnected.dispose();
    _instances.remove(device.remoteId.str);
  }
}

/// "Connection lost" dialog with Exit and Retry. The game is resumed automatically when the manikin comes back on
/// its own, or when the user taps Retry.
class BluetoothConnectionLostFunc {
  static bool isDialogOpen = false;
  static bool _isResuming = false;

  static void bluetoothLostConnectionDialog(BluetoothDevice device) {
    if (isDialogOpen) return;
    isDialogOpen = true;

    BluetoothLostConnectionAlertGetX().show(
      onPressExit: () async {
        _closeDialog();
        await BluetoothDevicesController().disConnectAndDisposeSelectedDevice(device);
        await Get.offAllNamed(RoutesNamed.home);
      },
      onPressRetry: () async {
        if (_isResuming) return;
        ProgressDialogue().show(Get.context, loadingText: 'Reconnecting...');
        final success = await _resume();
        await ProgressDialogue().hide(); // hide the progress dialog first, so closing the lost dialog pops the right route
        if (success) _closeDialog();
        alertToast2(success ? 'Reconnected successfully!' : 'Reconnection failed. Try again.');
      },
    )?.then((_) => isDialogOpen = false);
  }

  /// The device came back on its own (power restored, cable re-seated) while the dialog is showing:
  /// resume the game without asking the user to press retry.
  static void onDeviceConnected(BluetoothDevice device) {
    if (isDialogOpen && !_isResuming) {
      _resume().then((success) {
        if (success) _closeDialog();
      });
    }
  }

  static Future<bool> _resume() async {
    if (_isResuming) return false;
    _isResuming = true;
    try {
      return await BluetoothDevicesController().reconnectAndResume();
    } finally {
      _isResuming = false;
    }
  }

  static void _closeDialog() {
    if (isDialogOpen && (Get.isDialogOpen ?? false)) Get.back();
    isDialogOpen = false;
  }
}
