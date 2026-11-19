import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';

/// End-of-session result: total / correct / incorrect compressions with Exit and Retry.
class ResultDialog extends StatefulWidget {
  const ResultDialog({super.key, required this.isSuccess, required this.total, required this.correct, required this.incorrect, required this.onRetry, required this.onExit});

  final bool isSuccess;
  final int total;
  final int correct;
  final int incorrect;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
  late final Animation<double> _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.isSuccess;
    final color = ok ? AppColors.green : AppColors.red;
    return PopScope(
      canPop: false,
      child: ScaleTransition(
        scale: _scale,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 60),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                child: Column(
                  spacing: 24,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      spacing: 10,
                      children: [
                        Text(ok ? 'Awesome!' : 'Try Again', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                        Text(ok ? 'You nailed it!' : 'Better luck next time', style: const TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(label: 'Total', value: widget.total, color: Colors.black),
                        _Stat(label: 'Correct', value: widget.correct, color: Colors.green),
                        _Stat(label: 'Incorrect', value: widget.incorrect, color: Colors.red),
                      ],
                    ),
                    Row(
                      spacing: 20,
                      children: [
                        Expanded(child: GradientButton(gradientColors: AppColors.warningGradient, elevation: 4, title: 'Exit', onTap: widget.onExit)),
                        Expanded(child: GradientButton(gradientColors: ok ? AppColors.successGradient : null, elevation: 4, title: 'Retry', onTap: widget.onRetry)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Icon(ok ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded, color: Colors.white, size: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        Text('$value', style: GoogleFonts.bangers(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
