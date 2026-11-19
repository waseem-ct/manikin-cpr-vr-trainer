import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../AppManager/app_color.dart';
import '../../AppManager/my_text_theme.dart';
import '../../App_Constant/app_constant.dart';
import '../new_widgets/scaffold_widget.dart';
import 'splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: AppColor.white,
      safeAreColor: AppColor.white,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Opacity(opacity: value.clamp(0.0, 1.0), child: Transform.scale(scale: value, child: child)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppConstant.appLogo, width: 48.w),
              SizedBox(height: 2.h),
              Text(AppConstant.appName, style: MyTextTheme().largePrp.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
