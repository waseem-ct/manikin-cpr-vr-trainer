import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_constants.dart';
import '../theme/app_text_styles.dart';

/// Full-screen blocking loader with a short message.
class ProgressDialog extends StatelessWidget {
  const ProgressDialog({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(AppAssets.loader, height: 120),
              const SizedBox(height: 8),
              Text(text, style: AppTextStyles.whiteMedium),
            ],
          ),
        ),
      ),
    );
  }
}
