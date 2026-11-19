import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../AppManager/app_color.dart';
import '../../App_Constant/app_constant.dart';

class MyScaffold extends StatefulWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? bottomSheet;
  final Color? safeAreColor;
  final Color? backgroundColor;
  final bool? extendBodyBehindAppBar;
  final bool? showGradientSafeArea;
  final bool? resizeToAvoidBottomInset;
  final bool keepScreenOn;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  const MyScaffold(
      {super.key,
      required this.child,
      this.appBar,
      this.bottomNavigationBar,
      this.floatingActionButton,
      this.bottomSheet,
      this.backgroundColor,
      this.safeAreColor,
      this.extendBodyBehindAppBar,
      this.resizeToAvoidBottomInset,
      this. safeAreaTop = true,
      this. safeAreaBottom = true,
      this.showGradientSafeArea = true,
      this.keepScreenOn = false});

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.keepScreenOn) {
      WakelockPlus.enable();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.keepScreenOn) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.keepScreenOn) {
      if (state == AppLifecycleState.resumed) {
        WakelockPlus.enable();
      } else if (state == AppLifecycleState.paused) {
        WakelockPlus.disable();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: widget.showGradientSafeArea == false ? widget.safeAreColor : null, gradient: widget.showGradientSafeArea == true ? LinearGradient(colors: AppColor.linearGradientSafeArea) : null),
      child: SafeArea(
        top: widget.safeAreaTop,
        bottom: widget.safeAreaBottom,
        child: Container(
          height: Get.height,
          width: Get.width,
          decoration: widget.backgroundColor != null ? const BoxDecoration() : const BoxDecoration(image: DecorationImage(image: AssetImage(AppConstant.backGroundImage), fit: BoxFit.fill)),
          child: Scaffold(
            backgroundColor: widget.backgroundColor ?? Colors.transparent,
            body: Container(padding: widget.appBar == null ? EdgeInsets.zero : EdgeInsets.only(top: widget.appBar!.preferredSize.height.toDouble()), height: Get.height, width: Get.width, child: widget.child),
            appBar: widget.appBar,
            bottomNavigationBar: widget.bottomNavigationBar,
            floatingActionButton: widget.floatingActionButton,
            extendBodyBehindAppBar: widget.extendBodyBehindAppBar ?? false,
            resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            bottomSheet: widget.bottomSheet,
          ),
        ),
      ),
    );
  }
}

