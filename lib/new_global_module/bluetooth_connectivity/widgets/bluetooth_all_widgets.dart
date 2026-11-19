import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:manikin_simulator/AppManager/widgets/custom_gradient_button.dart';
import '../../../AppManager/my_text_theme.dart';
import '../../new_widgets/scaffold_widget.dart';
import '../bluetooth_devices_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BluetoothStateAndScanWidget
//
// FIX: Was calling Get.put(BluetoothDevicesController()) which created a new
//      orphan controller instance every time this widget built — disconnected
//      from the one registered by BluetoothDevicesView. This caused:
//        • requestBluetoothOn acting on the wrong instance
//        • rippleController animation not found / crash
//        • isLoading spinner never updating in the real view
//
//      Now uses Get.find which reuses the existing registered instance.
//      If for some reason the controller isn't registered yet (e.g. shown
//      standalone), it falls back to Get.put safely.
// ─────────────────────────────────────────────────────────────────────────────

class BluetoothStateAndScanWidget extends StatelessWidget {
  final BluetoothAdapterState state;
  final bool? isScanningView;

  const BluetoothStateAndScanWidget({
    Key? key,
    required this.state,
    this.isScanningView = false,
  }) : super(key: key);

  // ── FIX: find existing instance instead of creating a new orphan ──────────
  BluetoothDevicesController get controller => Get.isRegistered<BluetoothDevicesController>() ? Get.find<BluetoothDevicesController>() : Get.put(BluetoothDevicesController());

  Size get size => Get.mediaQuery.size;
  bool get isScanning => isScanningView == true;

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      showGradientSafeArea: false,
      safeAreColor: isScanning ? Colors.transparent : Colors.black,
      backgroundColor: isScanning ? Colors.transparent : Colors.black,
      child: _primaryScreen(),
    );
  }

  Widget _primaryScreen() {
    return Visibility(
      visible: isScanning,
      replacement: _buildBluetoothOffScreen(),
      child: SizedBox(
        height: Get.height / 3,
        child: Obx(() => BluetoothScanningWidget(
              animation: controller.rippleController.value,
              icon: _buildIconOpacityAnimation(
                opacity: controller.opacityAnimationVisible.value,
                iconSize: 65,
              ),
            )),
      ),
    );
  }

  Widget _buildBluetoothOffScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: Get.height / 3,
          width: 250,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Obx(() => _buildIconOpacityAnimation(opacity: controller.opacityAnimationVisible.value)),
              CustomPaint(painter: CustomAnim()),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text('Bluetooth Adapter is ${state == BluetoothAdapterState.on ? "On" : "Off"}', style: MyTextTheme().mediumWCB.copyWith(fontSize: size.width / 28)),
        const SizedBox(height: 15),
        CustomGradientButton(
          width: Get.width / 3,
          backgroundColor: Colors.green,
          title: 'Turn On',
          textStyle: MyTextTheme().mediumWCB.copyWith(fontSize: size.width / 28),
          onTap: controller.requestBluetoothOn,
        ),
      ],
    );
  }

  Widget _buildIconOpacityAnimation({required bool opacity, double? iconSize}) {
    return AnimatedOpacity(
      opacity: opacity ? 1.0 : 0.0,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 100),
      child: Obx(() => Icon(
            Icons.bluetooth,
            size: iconSize ?? 200.0,
            color: Colors.white.withValues(alpha: controller.rippleController.value.value),
          )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BluetoothScanningWidget — unchanged, but also uses Get.find
// ─────────────────────────────────────────────────────────────────────────────

class BluetoothScanningWidget extends GetView<BluetoothDevicesController> {
  final Animation<double> animation;
  final Widget? icon;

  const BluetoothScanningWidget({
    Key? key,
    required this.animation,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (final radius in [100.0, 170.0, 230.0, 290.0, 350.0]) _buildContainer(radius * animation.value),
            icon ?? const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Get.theme.primaryColor.withValues(alpha: 1 - controller.rippleController.value.value),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomAnim — unchanged
// ─────────────────────────────────────────────────────────────────────────────

class CustomAnim extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// RippleCustomPaint — unchanged
// ─────────────────────────────────────────────────────────────────────────────

class RippleCustomPaint extends CustomPainter {
  final double animationValue;
  RippleCustomPaint(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (int value = 3; value >= 0; value--) {
      _circle(canvas, Rect.fromLTRB(0, 0, size.width, size.height), value + animationValue);
    }
  }

  void _circle(Canvas canvas, Rect rect, double value) {
    canvas.drawCircle(
      rect.center,
      sqrt((rect.width * .4 * rect.width * .4) * value / 4),
      Paint()..color = Colors.deepPurple.withValues(alpha: (1 - (value / 4)).clamp(0.0, 1.0)),
    );
  }

  @override
  bool shouldRepaint(RippleCustomPaint old) => old.animationValue != animationValue;
}
