import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/cpr_sensor_data.dart';

/// Shown after every 30 compressions for the rescue breaths.
///
/// * [withAirBlow] true: the user must blow into the manikin twice; the dialog cannot be dismissed and closes
///   itself (from the provider) one second after the second breath.
/// * [withAirBlow] false: only a "Now give rescue breath" prompt with an OK button.
class AirBlowDialog extends StatelessWidget {
  const AirBlowDialog({super.key, required this.withAirBlow, required this.breathCount, required this.airBlowValue});

  final bool withAirBlow;
  final ValueListenable<int> breathCount;
  final ValueListenable<double> airBlowValue;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (withAirBlow)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(AppConstants.airBlowRequiredMessage, textAlign: TextAlign.center, style: AppTextStyles.whiteMediumBold.copyWith(fontSize: 15)),
              ),
            Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    withAirBlow ? _BreathCounter(breathCount: breathCount, airBlowValue: airBlowValue) : const _PromptBox(),
                    if (!withAirBlow) GradientOkButton(onTap: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptBox extends StatelessWidget {
  const _PromptBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.screenWidth * 0.6,
      height: context.screenHeight * 0.2,
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 5),
        gradient: const LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(context.screenWidth / 4),
      ),
      child: Text(AppConstants.airBlowPromptMessage, textAlign: TextAlign.center, style: AppTextStyles.whiteLarge.copyWith(fontSize: 16)),
    );
  }
}

class _BreathCounter extends StatelessWidget {
  const _BreathCounter({required this.breathCount, required this.airBlowValue});

  final ValueListenable<int> breathCount;
  final ValueListenable<double> airBlowValue;

  @override
  Widget build(BuildContext context) {
    final size = context.screenHeight / 3;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(AppAssets.airBlow, height: size, width: size),
            Positioned(
              bottom: context.screenHeight * 0.2,
              child: ValueListenableBuilder<double>(
                valueListenable: airBlowValue,
                builder: (_, value, __) => Visibility(visible: value > CprSensorData.airBlowThreshold, child: Lottie.asset(AppAssets.greenDot, height: 50, width: 50)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ValueListenableBuilder<int>(
          valueListenable: breathCount,
          builder: (_, count, __) => FloatingActionButton.large(
            onPressed: null,
            child: count >= 2 ? Lottie.asset(AppAssets.success) : Text('$count', style: AppTextStyles.darkHugeBold.copyWith(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

/// Orange "OK" button used by the prompt-only variant.
class GradientOkButton extends StatelessWidget {
  const GradientOkButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6600), minimumSize: Size(context.screenWidth * 0.3, 44)),
      child: Text('OK', style: AppTextStyles.whiteMediumBold),
    );
  }
}
