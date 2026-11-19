import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/cpr_layout.dart';
import '../../domain/entities/cpr_sensor_data.dart';

/// The manikin picture with live dots on it: red on a wrongly pressed side, red/green on the chest centre.
class ManikinStage extends StatelessWidget {
  const ManikinStage({super.key, required this.layout, required this.sensor, required this.width, required this.height});

  final CprLayout layout;
  final CprSensorData sensor;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget dot({required bool visible, String asset = AppAssets.redDot}) => Visibility(visible: visible, child: Lottie.asset(asset, height: height * 0.08, width: width * layout.gap));

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Image.asset(layout.image, fit: BoxFit.cover),
          Positioned(top: height * layout.leftDotTop, right: layout.leftDotRight, left: width * layout.leftDotLeft, child: dot(visible: sensor.isLeftIncorrect)),
          Positioned(
            top: height * layout.centerDotTop,
            right: layout.centerDotRight,
            left: layout.centerDotLeft,
            child: dot(visible: sensor.pressure > 0, asset: sensor.pressure > 5 ? AppAssets.greenDot : AppAssets.redDot),
          ),
          Positioned(top: height * layout.rightDotTop, right: width * layout.rightDotRight, left: layout.rightDotLeft, child: dot(visible: sensor.isRightIncorrect)),
        ],
      ),
    );
  }
}
