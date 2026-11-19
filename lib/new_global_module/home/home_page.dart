import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../AppManager/widgets/custom_gradient_button.dart';
import '../../App_Constant/app_constant.dart';
import '../new_widgets/scaffold_widget.dart';
import '../routing/route_names.dart';
import 'home_controller.dart';

/// Dashboard shown after the splash: the CPR manikin and a Play button that opens the Bluetooth device list.
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) controller.onPopInvoked();
      },
      child: MyScaffold(
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color.fromRGBO(233, 229, 255, 0.5)),
                child: Image.asset(AppConstant.adultCPRImage),
              ),
              CustomGradientButton(width: Get.width * 0.7, title: "Play", onTap: () => Get.toNamed(RoutesNamed.bluetoothDevices)),
            ],
          ),
        ),
      ),
    );
  }
}
