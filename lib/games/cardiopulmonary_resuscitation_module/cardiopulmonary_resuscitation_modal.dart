import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:manikin_simulator/Services/hex_color.dart';
import 'package:manikin_simulator/games/common_widgets/game_export_class.dart';
import 'package:sizer/sizer.dart';
import '../../AppManager/app_color.dart';
import '../../AppManager/my_text_theme.dart';

import '../../App_Constant/app_constant.dart';
import '../../new_global_module/new_widgets/button_widget.dart';

class CPRApiModal {
  /// Dependencies
  Timer? _airBlowTimer;

  /// Air Blow Counters
  RxInt secondAirBlow = 20.obs, correctAirBlowCounter = 0.obs;
  RxBool isAirBlowDialogOpen = false.obs;

  static const String dialogTitle = "This Page Is Auto Closed When Time Is Over";

  void _startCountdownForAirBlowDialog(RxInt second) async {
    ///AirBlow Flag =>_isAirBlowDialogOpen
    isAirBlowDialogOpen.value = true;
    correctAirBlowCounter.value = 0;
    secondAirBlow.value = 20;
    if (isAirBlowDialogOpen.isTrue && second.value.isLowerThan(1)) {
      _airBlowTimer!.cancel();
      Get.back();
    }
    _airBlowTimer = await Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (secondAirBlow.value > 0) {
        secondAirBlow.value--;
      } else {
        _airBlowTimer!.cancel();
        Get.back();
      }
    });

  }

  ///AirBlow Alertdialog
  Future<void> buildAirBlowDialog(bool isCprWithAirBlow, {required RxInt second, required double airBlowValue}) async {

    final TextStyle titleStyle = MyTextTheme().mediumWCB.copyWith(fontSize: 11.sp);
    Widget _floatingCountBox = await Obx(() {

      if (correctAirBlowCounter.value.isEqual(2)) {
        Future.delayed(Duration(seconds: 1), () {
          _airBlowTimer!.cancel();
          Get.back();
        });
      }
      return Visibility(
          visible: correctAirBlowCounter.value.isEqual(2),
          replacement: Text(correctAirBlowCounter.value.toString(), style: MyTextTheme().veryLargeBCB.copyWith(fontSize: 25.sp)),
          child: Lottie.asset(AppConstant.successAnimation));
    });
    if (isAirBlowDialogOpen.isFalse && second.value.isGreaterThan(1)) {
      _startCountdownForAirBlowDialog(second);
      await Get.defaultDialog(
          barrierDismissible: false,
          onWillPop: () {
            isAirBlowDialogOpen.value = false;
            _airBlowTimer!.cancel();
            return Future.value(false);
          },
          radius: 30,
          backgroundColor: isCprWithAirBlow ? Colors.deepPurple : AppColor.transparent,
          title: isCprWithAirBlow ? dialogTitle : "",
          titleStyle: titleStyle,
          titlePadding: EdgeInsets.only(left: 10, right: 10, top: 15),
          content: Obx(() => Text('Timer : ${secondAirBlow.value}', style: titleStyle.copyWith(fontSize: 13.sp))),
          confirm: Visibility(
            visible: !isCprWithAirBlow,
            child: MyButton(
              width: Get.width * 0.3,
              onTap: () {
                _airBlowTimer!.cancel();
                isAirBlowDialogOpen.value = false;
                Get.back();
              },
              backgroundColor: "#FF6600".toColor(),
              title: "OK",
            ),
          ),
          cancel: Visibility(
            visible: isCprWithAirBlow,
            replacement: _buildAirBlowAlertBox(),
            child: _buildAirBlowContent(airBlowValue, _floatingCountBox),
          )).whenComplete(() => isAirBlowDialogOpen.value = false);
    }
  }

  /// Helper to build AirBlow Alert Box
  Widget _buildAirBlowAlertBox() {
    return Container(
      width: Get.width * 0.6,
      height: Get.height * 0.2,
      padding: EdgeInsets.all(30),
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 5), color: AppColor.proPurple, borderRadius: BorderRadius.circular(Get.width / 4)),
      child: Text(AppConstant.airBlowAlertMsg, textAlign: TextAlign.center, style: MyTextTheme().largeWCN.copyWith(fontSize: 14.sp)),
    );
  }

  /// Helper to build AirBlow Content with animation and buttons
  Widget _buildAirBlowContent(double airBlowValue, Widget floatingCountBox) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Image.asset(AppConstant.air_blow_image, height: Get.size.height / 3, width: Get.size.height / 3),

            /// Green dot animation for successful air blow
            Positioned(
              left: 0,
              right: 0,
              bottom: 20.h,
              child: Visibility(visible: airBlowValue > 1.25, child: Lottie.asset(AppConstant.greenDotAnimation, height: 50, width: 50)),
            ),
          ],
        ),
        SizedBox(height: 15),
        _buildFloatingActionButton(floatingCountBox),
        SizedBox(height: 15),
      ],
    );
  }

  /// Helper for Floating Action Button or Large Button
  Widget _buildFloatingActionButton(Widget floatingCountBox) {
    return Visibility(
      visible: SizerUtil.deviceType == DeviceType.mobile,
      replacement: FloatingActionButton.large(onPressed: null, child: floatingCountBox),
      child: FloatingActionButton(onPressed: null, child: floatingCountBox),
    );
  }
}
