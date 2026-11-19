import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Top bar: a back button on the left, an optional centre widget / title, and a trailing widget on the right.
///
/// The trailing slot is either [trailing] (already styled by the caller) or, by default, a round button with
/// [trailingIcon]. With [compact] the bar is slim (40 px buttons, small margins) for game screens.
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
    this.compact = false,
    this.margin,
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
  final bool compact;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 22.0 : 30.0;
    return Padding(
      padding: margin ?? (compact ? const EdgeInsets.fromLTRB(12, 4, 12, 2) : const EdgeInsets.all(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RoundedIconButton(onTap: onBack, color: AppColors.purple, compact: compact, child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: iconSize)),
          if (center != null) Expanded(child: Center(child: center)) else if (title != null) Text(title!, style: AppTextStyles.purpleLarge.copyWith(fontSize: 18)),
          trailing ?? RoundedIconButton(onTap: onTrailingTap, color: trailingColor ?? AppColors.purple, compact: compact, child: trailingIcon ?? Icon(Icons.more_horiz, color: Colors.white, size: iconSize)),
        ],
      ),
    );
  }
}

/// Purple rounded button used in the header. [compact] makes it a 40 x 40 button.
class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({super.key, required this.child, required this.color, this.onTap, this.compact = false});

  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 52.0;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(compact ? 12 : 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 12 : 18),
        onTap: onTap,
        child: SizedBox(width: size, height: size, child: Center(child: child)),
      ),
    );
  }
}
