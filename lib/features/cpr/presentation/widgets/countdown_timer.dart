import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

/// Circular 60 s countdown with the current attempt number next to it.
class CountdownTimer extends StatelessWidget {
  const CountdownTimer({super.key, required this.seconds, required this.totalSeconds, required this.attempt});

  final int seconds;
  final int totalSeconds;
  final int attempt;

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final percent = (seconds / totalSeconds).clamp(0.0, 1.0);
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularPercentIndicator(
                linearGradient: const LinearGradient(colors: [Colors.white, Colors.white]),
                animateFromLastPercent: true,
                animation: true,
                circularStrokeCap: CircularStrokeCap.round,
                radius: context.screenHeight * 0.043,
                lineWidth: context.screenHeight * 0.007,
                percent: percent,
                center: Text('$seconds', style: AppTextStyles.timer.copyWith(fontSize: width / 16)),
              ),
              Container(
                decoration: const BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)), color: Colors.deepPurple),
                padding: const EdgeInsets.all(7),
                child: Text(attempt > 1 ? '$attempt  Attempts' : ' $attempt Attempt', style: AppTextStyles.whiteMedium.copyWith(fontSize: width / 30, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Positioned(left: 28, top: 0, child: Container(height: 6, width: 15, color: AppColors.white)),
      ],
    );
  }
}
