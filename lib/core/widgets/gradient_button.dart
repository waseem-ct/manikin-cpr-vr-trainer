import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Rounded gradient button. If [onTap] returns a Future the button shows a spinner until it completes.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.title,
    this.onTap,
    this.height = 48,
    this.width,
    this.elevation = 2,
    this.textStyle,
    this.gradientColors,
    this.backgroundColor,
  });

  final String title;
  final FutureOr<void> Function()? onTap;
  final double? height;
  final double? width;
  final double elevation;
  final TextStyle? textStyle;
  final List<Color>? gradientColors;
  final Color? backgroundColor;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    final result = widget.onTap?.call();
    if (result is Future) {
      setState(() => _isLoading = true);
      try {
        await result;
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.backgroundColor;
    return InkWell(
      onTap: widget.onTap == null || _isLoading ? null : _handlePress,
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            gradient: color == null ? LinearGradient(end: Alignment.centerRight, colors: widget.gradientColors ?? AppColors.primaryGradient) : null,
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.elevation > 0
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), spreadRadius: widget.elevation * 0.5, blurRadius: widget.elevation * 2, offset: Offset(0, widget.elevation))]
                : null,
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : Text(widget.title, style: widget.textStyle ?? AppTextStyles.whiteLarge.copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
