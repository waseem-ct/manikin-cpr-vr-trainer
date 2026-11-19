import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Top bar: a back button on the left, an optional centre widget / title, and a trailing widget on the right.
///
/// The trailing slot is either [trailing] (already styled by the caller) or, by default, a round button with
/// [trailingIcon] (e.g. the Bluetooth settings shortcut on the device list).
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.onBack,
    this.onTrailingTap,
    this.title,
    this.center,
    this.trailing,
    this.trailingIcon,
    this.trailingColor,
    this.margin = const EdgeInsets.all(20),
  });

  final VoidCallback? onBack;
  final VoidCallback? onTrailingTap;
  final String? title;

  /// Replaces [title] with any widget (e.g. the coloured "Connected" label).
  final Widget? center;

  /// Fully custom trailing widget; overrides [trailingIcon].
  final Widget? trailing;
  final Widget? trailingIcon;
  final Color? trailingColor;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RoundedIconButton(
            onTap: onBack,
            color: AppColors.purple,
            child: const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30)),
          ),
          if (center != null) center! else if (title != null) Text(title!, style: AppTextStyles.purpleLarge.copyWith(fontSize: 18)),
          trailing ??
              RoundedIconButton(
                onTap: onTrailingTap,
                color: trailingColor ?? AppColors.purple,
                child: trailingIcon ?? const Icon(Icons.more_horiz, color: Colors.white, size: 30),
              ),
        ],
      ),
    );
  }
}

/// Purple rounded button used in the header.
class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({super.key, required this.child, required this.color, this.onTap});

  final Widget child;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      onPressed: onTap,
      style: ButtonStyle(shape: WidgetStatePropertyAll(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))), backgroundColor: WidgetStatePropertyAll(color)),
      icon: child,
    );
  }
}
