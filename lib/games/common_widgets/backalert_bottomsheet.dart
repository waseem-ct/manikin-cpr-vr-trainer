import 'package:flutter/material.dart';

import '../../AppManager/getxDialog&BottomSheet&progressDialog/getXsheet&dialog&progressDialog.dart';
import '../../AppManager/progress_dialogue.dart';
import '../../App_Constant/app_constant.dart';
import '../../new_global_module/bluetooth_connectivity/bluetooth_devices_controller.dart';
import '../../new_global_module/routing/route_names.dart';
import 'game_export_class.dart';

class BackAlertBottomSheet {
  /// Asks for confirmation, then disconnects the manikin and returns to the dashboard.
  static void exit({required BluetoothDevice device, Future<void> Function()? beforeExit}) {
    getXBottomSheet(
        buttonName: 'Exit',
        message: AppConstant.exitMsg,
        onPressButton: () async {
          ProgressDialogue().show(Get.context, loadingText: 'Exiting');
          try {
            await beforeExit?.call();
            await BluetoothDevicesController()
                .disConnectAndDisposeSelectedDevice(device)
                .timeout(const Duration(seconds: 4), onTimeout: () => debugPrint('Disconnect timed out, continuing'));
          } catch (e) {
            debugPrint('Exit error: $e');
          } finally {
            await ProgressDialogue().hide();
          }
          Get.back(); // close the bottom sheet
          Future.microtask(() => Get.offAllNamed(RoutesNamed.home));
        });
  }

  /// Turns the manikin's data notifications on/off (off while the result is shown, on again for a retry).
  static Future<void> stopNotifications({required BluetoothDevice device, required String serviceUuid, required String charUuid, bool? isListen = false}) async {
    try {
      final services = await device.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().toUpperCase().contains(serviceUuid)) {
          for (var char in service.characteristics) {
            if (char.uuid.toString().toUpperCase().contains(charUuid)) {
              await char.setNotifyValue(isListen ?? false);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error stopping notifications: $e");
    }
  }
}
