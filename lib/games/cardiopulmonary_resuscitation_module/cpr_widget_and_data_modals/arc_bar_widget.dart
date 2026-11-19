// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../AppManager/app_color.dart';
import '../../../AppManager/my_text_theme.dart';

class ResponsiveRadialGauge extends StatefulWidget {
  final int value;
  final String totalCount;

  ResponsiveRadialGauge({required this.value, required this.totalCount});

  @override
  State<ResponsiveRadialGauge> createState() => _ResponsiveRadialGaugeState();
}

class _ResponsiveRadialGaugeState extends State<ResponsiveRadialGauge> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initialization();
  }

  _initialization() {
    // Adjust duration to 500ms for smoother animation
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _animation = Tween<double>(begin: 0.0, end: widget.value.toDouble()).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ResponsiveRadialGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value.toDouble()).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
      _animationController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              double containerHeight = constraints.maxHeight * 0.35;
              double containerWidth = constraints.maxWidth;
              double labelFontSize = containerHeight * 0.06;
              double thickness = 0.16;
              return Container(
                  height: containerHeight,
                  width: containerWidth,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(90), topRight: Radius.circular(90)),
                    gradient: LinearGradient(colors: [Color(0xFFA14AF9), Color(0xFF0ED6FF)], begin: Alignment.topLeft, end: Alignment.bottomRight, tileMode: TileMode.clamp),
                  ),
                  padding: EdgeInsets.only(bottom: 24),
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SfRadialGauge(

                        enableLoadingAnimation: true,
                        // animationDuration: 20,
                        title: GaugeTitle(text: " ", textStyle: TextStyle(color: AppColor.transparent, fontSize: containerHeight * 0.1)),
                        axes: <RadialAxis>[
                          RadialAxis(
                              interval: 25,
                              startAngle: 175,
                              endAngle: 5,
                              showLastLabel: true,
                              showLabels: true,
                              axisLabelStyle: GaugeTextStyle(color: AppColor.white, fontSize: labelFontSize, fontWeight: FontWeight.bold),
                              axisLineStyle: AxisLineStyle(thickness: thickness, thicknessUnit: GaugeSizeUnit.factor, color: Color(0xFFA2EEFF), cornerStyle: CornerStyle.bothCurve),
                              canScaleToFit: true,
                              radiusFactor: 1.2,
                              annotations: [
                                GaugeAnnotation(
                                    positionFactor: 1.06,
                                    axisValue: 50,
                                    verticalAlignment: GaugeAlignment.far,
                                    widget: Text("Pressure", style: TextStyle(color: AppColor.white, fontWeight: FontWeight.bold, fontSize: containerHeight * 0.1))),
                                GaugeAnnotation(
                                  horizontalAlignment: GaugeAlignment.center,
                                  verticalAlignment: GaugeAlignment.center,
                                  widget: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.white),
                                      padding: EdgeInsets.all(30),
                                      child: Text(widget.totalCount.toString(), style: MyTextTheme().extraLargeWCB.copyWith(color: Color(0xFF4B73F1), fontSize: containerHeight * 0.3))),
                                ),
                              ],
                              pointers: <GaugePointer>[
                                RangePointer(
                                  value: _animation.value * 10,
                                  cornerStyle: CornerStyle.bothCurve,
                                  width: thickness,
                                  animationType: AnimationType.bounceOut,
                                  sizeUnit: GaugeSizeUnit.factor,
                                  color: Colors.white,
                                  // gradient: const SweepGradient(
                                  //     startAngle: 0,
                                  //     endAngle: 100,
                                  //     tileMode: TileMode.repeated,
                                  //     center: Alignment.center,
                                  //     stops: [0.0, 0.33, 0.66, 1.0],
                                  //     colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green])
                                ),
                              ]),

                        ]),
                  ));
            },
          );
        });
  }
}
