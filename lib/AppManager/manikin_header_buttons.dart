import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'app_color.dart';
import 'my_text_theme.dart';

class MyCustomHeaderButton extends StatefulWidget {
  final void Function()? leadingTap;
  final void Function()? trailingTap;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Color? trailingBackGroundColor;
  final Color? leadingBackgroundColor;
  final bool? isHideLeadingBg;
  final bool? isHideTrailingBg;
  final bool? isVisibleBackButton;
  final bool? isConnected;
  final EdgeInsets? containerMargin;
  final EdgeInsets? contentPadding;
  final String? centerText;
  final TextStyle? textStyle;
  const MyCustomHeaderButton(
      {Key? key,
      this.leadingTap,
      this.trailingTap,
      this.trailingIcon,
      this.leadingBackgroundColor,
      this.centerText,
      this.textStyle,
      this.isVisibleBackButton = true,
      this.trailingBackGroundColor,
      this.leadingIcon,
      this.containerMargin = const EdgeInsets.all(20.0),
      this.contentPadding,
      this.isHideLeadingBg = false,
      this.isHideTrailingBg = false,
      this.isConnected})
      : super(key: key);

  @override
  State<MyCustomHeaderButton> createState() => _MyCustomHeaderButtonState();
}

class _MyCustomHeaderButtonState extends State<MyCustomHeaderButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.containerMargin!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: widget.isVisibleBackButton == true,
            replacement: SizedBox(),
            child: _decoratedContainer(
                child: widget.leadingIcon ??
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                    ),
                onTap: widget.leadingTap,
                color: widget.isHideLeadingBg == true ? Colors.transparent : widget.leadingBackgroundColor),
          ),
          if (widget.centerText != null)
            Text(
              widget.centerText.toString(),
              style: widget.textStyle ?? MyTextTheme().largePrp.copyWith(fontFamily: 'Poppins-Medium', fontSize: 14.sp),
            ),
          _decoratedContainer(
              onTap: widget.trailingTap,
              color: widget.isHideTrailingBg == true ? Colors.transparent : widget.trailingBackGroundColor ?? (widget.isConnected != null && widget.isConnected == true ? AppColor.green : AppColor.red),
              child: widget.trailingIcon ?? Icon(widget.isConnected == true ? Icons.bluetooth_connected_sharp : Icons.bluetooth_disabled_sharp, color: Colors.white, size: 30))
        ],
      ),
    );
  }

  Widget _decoratedContainer({required Widget child, void Function()? onTap, color}) {
    return IconButton(
        padding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 14),
        onPressed: onTap,
        style:
            ButtonStyle(shape: WidgetStatePropertyAll(ContinuousRectangleBorder(borderRadius: BorderRadiusGeometry.circular(30))), backgroundColor: WidgetStatePropertyAll(color ?? AppColor.proPurple)),
        icon: child);
  }
}
