import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../services/retry_dialog.dart';

/// Dashboard controller: the only thing it does is confirm before the app is closed.
class HomeController extends GetxController {
  Future<void> onPopInvoked() async {
    await RetryDialog.showDefaultDialog(Get.context!,
        canPop: false, title: "Are You Sure ?", message: 'Do You Want To Exit!', trailingButtonText: "Confirm", leadingButtonText: "Cancel", onPressedTrailing: () {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    });
  }
}
