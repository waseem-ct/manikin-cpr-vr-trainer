import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../new_global_module/new_widgets/button_widget.dart';
import 'app_color.dart';
import 'my_text_theme.dart';

class FunctionalSheet extends StatelessWidget {
  final String message;
  final String buttonName;
  final Function onPressButton;
  final bool showCancelButton;
  final TextAlign? textAlign;
  final Widget? child;
  final Color? confirmButtonColor;
  final TextStyle? textStyle;
  final TextStyle? buttonTextStyle;

  const FunctionalSheet(
      {Key? key,
      required this.message,
      required this.buttonName,
      required this.onPressButton,
      this.showCancelButton = true,
      this.textAlign,
      this.child,
      this.confirmButtonColor,
      this.textStyle,
      this.buttonTextStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      color: Colors.transparent,
      child: Column(
        spacing: 40,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            spacing: child == null ? 20 : 0,
            mainAxisSize: MainAxisSize.min,
            children: [
              child ?? Container(),
              Text(message.toString(), textAlign: textAlign ?? TextAlign.center, style: textStyle ?? MyTextTheme().mediumBCB.copyWith(fontSize: 15.sp)),
            ],
          ),
          Row(
            spacing: 25,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (showCancelButton)
                Expanded(
                  child: MyButton(
                      backgroundColor: Colors.black12,
                      titleTextStyle: TextStyle(fontSize: size.width / 28, color: Colors.white),
                      onTap: () => Get.back(),
                      title: buttonName.contains("Yes") ? "No" : "Cancel"),
                ),
              Expanded(
                child: MyButton(
                    backgroundColor: confirmButtonColor ?? AppColor.green,
                    titleTextStyle: buttonTextStyle ?? TextStyle(fontSize: size.width / 28, color: Colors.black),
                    onTap: () {
                      Get.back();
                      onPressButton();
                    },
                    title: buttonName),
              ),
            ],
          )
        ],
      ),
    );
  }
}
