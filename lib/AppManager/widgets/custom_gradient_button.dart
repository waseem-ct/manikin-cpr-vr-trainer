import 'dart:async'; // <-- for FutureOr
import 'package:flutter/material.dart';
import 'package:manikin_simulator/AppManager/app_color.dart';
import 'package:manikin_simulator/AppManager/my_text_theme.dart';

class CustomGradientButton extends StatefulWidget {
  final String title;
  final FutureOr<void> Function()? onTap;
  final double? height;
  final double? width;
  final double? elevation;
  final TextStyle? textStyle;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? borderRadius;
  final BorderSide? borderSide;
  final Widget? loadingWidget;
  const CustomGradientButton({
    Key? key,
    required this.title,
    this.onTap,
    this.height = 48,
    this.width,
    this.elevation = 2,
    this.textStyle,
    this.gradientColors,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius,
    this.borderSide,
    this.loadingWidget,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<CustomGradientButton> createState() => _CustomGradientButtonState();
}

class _CustomGradientButtonState extends State<CustomGradientButton> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.onTap == null) return;
    final result = widget.onTap!();
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
    return InkWell(
      onTap: _isLoading ? null : _handlePress,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? null,
            gradient: widget.backgroundColor == null ? LinearGradient(end: Alignment.centerRight, colors: widget.gradientColors ?? AppColor.linearGradientBG) : null,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 30),
            border: widget.borderSide != null ? Border.fromBorderSide(widget.borderSide!) : null,
            boxShadow: widget.elevation != null && widget.elevation! > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      spreadRadius: widget.elevation! * 0.5,
                      blurRadius: widget.elevation! * 2,
                      offset: Offset(0, widget.elevation!),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: _isLoading
                ? (widget.loadingWidget ?? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.prefixIcon != null) ...[widget.prefixIcon!, const SizedBox(width: 6)],
                      Text(widget.title, style: widget.textStyle ?? MyTextTheme().largeWCN.copyWith(fontWeight: FontWeight.w600)),
                      if (widget.suffixIcon != null) ...[widget.suffixIcon!, const SizedBox(width: 6)],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
