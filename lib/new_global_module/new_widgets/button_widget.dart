import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../AppManager/app_color.dart';
class MyButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String? title;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Color? backgroundColor;
  final double? buttonRadius;
  final double? width;
  final double? buttonSpacing;
  final double? height;
  final TextStyle? titleTextStyle;
  final bool? isLoadingButton;
  MyButton({
    super.key,
    required this.onTap,
    this.title = "Ok",
    this.backgroundColor,
    this.buttonRadius,
    this.width,
    this.height = 45,
    this.leadingIcon,
    this.trailingIcon,
    this.buttonSpacing,
    this.titleTextStyle,
    this.isLoadingButton = false,
  });

  final size = Get.mediaQuery.size;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
        fixedSize: Size(width ?? size.width / 1.2, height!),
        backgroundColor: backgroundColor ?? AppColor.proPurple,
        alignment: Alignment.center,
        shape: buttonRadius == null ? const StadiumBorder() : RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius!)));
    return ElevatedButton(onPressed: isLoadingButton == true ? null : onTap, style: buttonStyle, child: _buildButtonChild());
  }

  Widget _buildButtonChild() {
    return isLoadingButton == true ? _loadingIndicator() : _normalButtonContent();
  }

  Widget _loadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColor.white),
      ),
    );
  }

  Widget _normalButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[leadingIcon!, if (buttonSpacing != null) SizedBox(width: buttonSpacing)],
        Text(title!, style: titleTextStyle ?? Get.textTheme.titleSmall!.copyWith(color: AppColor.white)),
        if (trailingIcon != null) ...[if (buttonSpacing != null) SizedBox(width: buttonSpacing), trailingIcon!],
      ],
    );
    /*
     leadingIcon != null || trailingIcon != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leadingIcon == null ? const SizedBox() : leadingIcon!,
                SizedBox(width: buttonSpacing),
                Text(title!, style: TextStyle(color: AppColor.white)),
                SizedBox(width: buttonSpacing),
                trailingIcon == null ? const SizedBox() : trailingIcon!,
              ],
            )
          : Text(title!, style: titleTextStyle ?? Theme.of(context).textTheme.titleSmall!.copyWith(color: AppColor.white)),
     */
  }
}
