import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../AppManager/app_color.dart';
import '../../../AppManager/widgets/custom_gradient_button.dart';

class ResultDialog extends StatefulWidget {
  final bool isCorrect;
  final int total;
  final int correct;
  final int incorrect;
  final VoidCallback? onRetry;
  final VoidCallback? onExit;

  const ResultDialog({super.key, required this.isCorrect, required this.total, required this.correct, required this.incorrect, required this.onRetry, this.onExit});

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String titleOld = widget.isCorrect ? 'Success! You Got It Right' : 'Oops! Something Went Wrong';
    final String subtitleOld = widget.isCorrect ? 'Great job! Your answer was correct.' : 'It looks like that wasn\'t quite right. Please try again.';
    final String title = widget.isCorrect ? "🎉 Awesome!" : "😓 Try Again";
    final String subtitle = widget.isCorrect ? "You nailed it!" : "Better luck next time";
    final Color dialogColor = widget.isCorrect ? AppColor.green : AppColor.red;
    final IconData icon = widget.isCorrect ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded;
    // Define gradient based on correctness
    // Define gradient based on correctness
    final List<Color>? buttonGradient = widget.isCorrect ? [AppColor.green.withValues(alpha: 0.8), Colors.green.shade700] : null;
    return PopScope(
      canPop: false,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 60),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                child: Column(
                  spacing: 24,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      spacing: 10,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                        Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Total', widget.total.toString(), Colors.black),
                        _buildStat('Correct', widget.correct.toString(), Colors.green),
                        _buildStat('Incorrect', widget.incorrect.toString(), Colors.red)
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      spacing: 20,
                      children: [
                        Expanded(
                            child:
                                CustomGradientButton(gradientColors: [Color(0xFFF66524), Color(0xFFF8A52B)], onTap: widget.onExit, elevation: 4, title: 'Exit')),
                        Expanded(child: CustomGradientButton(gradientColors: buttonGradient, onTap: widget.onRetry ?? () => Navigator.of(context).pop(), elevation: 4, title: 'Retry')),
                      ],
                    ),
                  ],
                ),
              ),
              // Top icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: dialogColor,
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Icon(icon, color: Colors.white, size: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      spacing: 8,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        Text(value.toString(), style: GoogleFonts.bangers(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        SizedBox(height: 4),
      ],
    );
  }
}
