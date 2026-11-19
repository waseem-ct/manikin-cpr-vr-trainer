import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bottom half-circle gauge: live pressure on the arc, number of compressions counted in the centre.
class PressureGauge extends StatefulWidget {
  const PressureGauge({super.key, required this.pressure, required this.totalCount});

  final int pressure;
  final int totalCount;

  @override
  State<PressureGauge> createState() => _PressureGaugeState();
}

class _PressureGaugeState extends State<PressureGauge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  late Animation<double> _animation = _tween(0, widget.pressure.toDouble());

  Animation<double> _tween(double begin, double end) => Tween<double>(begin: begin, end: end).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(PressureGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pressure != oldWidget.pressure) {
      _animation = _tween(_animation.value, widget.pressure.toDouble());
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight * 0.35;
          const thickness = 0.16;
          return Container(
            height: height,
            width: constraints.maxWidth,
            padding: const EdgeInsets.only(top: 15),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(90), topRight: Radius.circular(90)),
              gradient: LinearGradient(colors: AppColors.gaugeGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: SfRadialGauge(
                enableLoadingAnimation: true,
                axes: <RadialAxis>[
                  RadialAxis(
                    interval: 25,
                    startAngle: 175,
                    endAngle: 5,
                    showLastLabel: true,
                    axisLabelStyle: GaugeTextStyle(color: AppColors.white, fontSize: height * 0.06, fontWeight: FontWeight.bold),
                    axisLineStyle: const AxisLineStyle(thickness: thickness, thicknessUnit: GaugeSizeUnit.factor, color: AppColors.gaugeTrack, cornerStyle: CornerStyle.bothCurve),
                    canScaleToFit: true,
                    radiusFactor: 1.2,
                    annotations: [
                      GaugeAnnotation(
                        positionFactor: 1.06,
                        axisValue: 50,
                        verticalAlignment: GaugeAlignment.far,
                        widget: Text('Pressure', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: height * 0.1)),
                      ),
                      GaugeAnnotation(
                        horizontalAlignment: GaugeAlignment.center,
                        verticalAlignment: GaugeAlignment.center,
                        widget: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                          padding: const EdgeInsets.all(30),
                          child: Text('${widget.totalCount}', style: AppTextStyles.whiteHugeBold.copyWith(color: AppColors.gaugeText, fontSize: height * 0.3)),
                        ),
                      ),
                    ],
                    pointers: <GaugePointer>[
                      RangePointer(
                          value: _animation.value * 10,
                          cornerStyle: CornerStyle.bothCurve,
                          width: thickness,
                          animationType: AnimationType.bounceOut,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
