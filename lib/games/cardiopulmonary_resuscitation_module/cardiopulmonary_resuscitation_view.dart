import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

import '../../AppManager/manikin_ main_circular_timer.dart';

import '../../AppManager/manikin_header_buttons.dart';
import '../../AppManager/my_text_theme.dart';
import '../../App_Constant/app_constant.dart';
import '../../new_global_module/new_widgets/scaffold_widget.dart';
import '../../new_global_module/services/base_controller.dart';
import '../common_widgets/game_export_class.dart';
import 'SerivicesVr/network_status_widget.dart';
import 'cardiopulmonary_resuscitation_controller.dart';
import 'cpr_widget_and_data_modals/arc_bar_widget.dart';

class CardiopulmonaryResuscitationView extends BasePage<CardiopulmonaryResuscitationController> {
  final controller = Get.put(CardiopulmonaryResuscitationController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async => controller.exitingGameBottomSheet(),
      child: MyScaffold(
        keepScreenOn: true,
        bottomNavigationBar: _bottomProgressArc(),
        child: _buildPrimaryView(),
      ),
    );
  }

  /// Primary Screen View
  Widget _buildPrimaryView() {
    return Obx(() {
      final config = controller.uiConfig.value;
      if (config == null || controller.args.pageId == null) {
        return SizedBox.shrink(
          child: Column(
              mainAxisSize: MainAxisSize.min, children: [Lottie.asset(AppConstant.unavailableData, height: Get.height * 0.3), Text("Game id is mismatched or empty!", style: MyTextTheme().mediumBCB)]),
        );
      }

      return Column(
        children: [
          GetBuilder<CardiopulmonaryResuscitationController>(
            builder: (_) {
              final connected = controller.isDeviceConnected;
              if (connected == null) return MyCustomHeaderButton(isConnected: true, leadingTap: controller.exitingGameBottomSheet);
              return ValueListenableBuilder<bool>(
                valueListenable: connected,
                builder: (_, isConnected, __) => MyCustomHeaderButton(isConnected: isConnected, leadingTap: controller.exitingGameBottomSheet),
              );
            },
          ),
          NetworkStatusWidget(pingStream: controller.monitor.pingStream),

          Expanded(
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              double _width = constraints.maxWidth;
              double _height = constraints.maxHeight;
              Widget _buildDotLottie({required bool visible, String? dotColor}) =>
                  Visibility(visible: visible, child: Lottie.asset(dotColor ?? AppConstant.redDotAnimation, height: _height * 0.08, width: _width * config.gap));
              return FittedBox(
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if ( Device.screenType == ScreenType.tablet) SizedBox(height: _height * 0.05),
                    if (SizerUtil.deviceType == DeviceType.tablet) SizedBox(height: _height * 0.05),

                    /// Timer widget
                    Obx(() {
                      return InkWell(
                          onTap: !kDebugMode
                              ? null
                              : () {
                                  // controller.resetTimer();
                                  // controller.initDataFetching();
                                  controller.showScoreDialog();
                                },
                          child: ManikinCircularTimerMain(
                              attempt: controller.totalNumberOfAttempt.value,
                              seconds: controller.second.value.toString(),
                              percent: controller.second.value / 60 < 0 ? 0 : controller.second.value / 60));
                    }),
                    SizedBox(height: _height * 0.05),

                    /// Manikin image
                    SizedBox(
                      height: _height * 1,
                      child: Stack(
                        children: [
                          ///CPR Image
                          Image.asset(config.image, fit: BoxFit.cover),

                          /// Left red dot
                          Positioned(
                              top: _height * config.leftRedDotTop,
                              right: config.leftRedDotRight,
                              left: _width * config.leftRedDotLeft,
                              child: Obx(() => _buildDotLottie(visible: controller.bluetoothResponseDataModal.value.leftCompression.isEqual(AppConstant.cprIncorrectA)))),

                          /// CPR red and green dots
                          Positioned(
                            top: _height * config.centerGreenRedDotTop,
                            right: config.centerGreenRedDotRight,
                            left: config.centerGreenRedDotLeft,
                            child: Obx(() => _buildDotLottie(
                                visible: controller.bluetoothResponseDataModal.value.cprValue.isGreaterThan(0),
                                dotColor: controller.bluetoothResponseDataModal.value.cprValue.isGreaterThan(5) ? AppConstant.greenDotAnimation : AppConstant.redDotAnimation)),
                          ),

                          /// Right red dot
                          Positioned(
                            top: _height * config.rightRedDotTop,
                            right: _width * config.rightRedDotRight,
                            left: config.rightRedDotLeft,
                            child: Obx(() => _buildDotLottie(visible: controller.bluetoothResponseDataModal.value.rightCompression.isEqual(AppConstant.cprIncorrectB))),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
        ],
      );
    });
  }

  /// bottomNavigation bar widget
  Widget _bottomProgressArc() {
    return Obx(() {
      return ResponsiveRadialGauge(value: controller.second.value.isEqual(0) ? 0 : controller.bluetoothResponseDataModal.value.cprValue, totalCount: controller.totalCompressionOfCpr.value.toString());
    });
  }
}
