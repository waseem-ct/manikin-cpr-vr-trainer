import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../functional_bottomSheet.dart';
import '../my_text_theme.dart';

getXBottomSheet({required String message, required String buttonName, VoidCallback? onPressButton, bool? showCancelButton, bool? barrierDismiss, bool? enableDrag}) {
  Get.bottomSheet(
      Container(
        decoration: BoxDecoration(color: Colors.deepPurple, border: Border.all(color: Colors.white), borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        child: FunctionalSheet(
          textStyle: MyTextTheme().largeWCB.copyWith(fontSize: Get.width / 25),
          confirmButtonColor: Colors.white,
          message: message,
          buttonName: buttonName,
          onPressButton: () => onPressButton!(),
          showCancelButton: showCancelButton ?? true,
        ),
      ),
      isDismissible: barrierDismiss ?? true,
      enableDrag: enableDrag ?? true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))));
}
