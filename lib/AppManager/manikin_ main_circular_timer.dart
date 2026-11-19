import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import 'app_color.dart';
import 'my_text_theme.dart';

class ManikinCircularTimerMain extends StatelessWidget {
  final double percent;
  final double? radius;
  final double? lineWidth;
  final int attempt;
  final String seconds;

  ManikinCircularTimerMain({Key? key, required this.percent, this.radius, this.lineWidth, required this.attempt, required this.seconds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                  linearGradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)]),
                  animateFromLastPercent: true,
                  animation: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  radius: radius ?? 4.3.h,
                  lineWidth: lineWidth ?? 0.7.h,
                  percent: percent,
                  center: Text(seconds.toString(), style: MyTextThemeBebas().veryLargeWCB.copyWith(fontSize: MediaQuery.of(context).size.width / 16))),
              Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)), color: Colors.deepPurple),
                  padding: const EdgeInsets.all(7),
                  alignment: Alignment.center,
                  child: Text(attempt > 1 ? '$attempt  Attempts' : ' $attempt Attempt',
                      style: MyTextTheme().mediumWCN.copyWith(fontSize: MediaQuery.of(context).size.width / 30, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        Positioned(left: 28, top: 0, child: Container(height: 6, width: 15, color: AppColor.white, margin: EdgeInsets.only(bottom: 4))),
      ],
    );
  }
}
