import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Services/tab_responsive.dart';
import 'app_color.dart';
import 'my_text_theme.dart';

alertToast2(message) => Fluttertoast.showToast(msg: message);

alertToast(context, message) {
  FocusScope.of(context).unfocus();
  Fluttertoast.showToast(msg: message);
}

class AlertDialogue2 {
  show(
    context, {
    String? alert,
    String? msg,
    String? firstButtonName,
    Function? firstButtonPressEvent,
    String? secondButtonName,
    Function? secondButtonPressEvent,
    bool? showCancelButton,
    bool? showOkButton,
    bool? disableDuration,
    bool? checkIcon,
    bool? hideIcon,
    bool? centerTitle,
    Widget? newWidget,
    List<Widget>? fullScreenWidget,
    String? title,
    String? subTitle,
    Color? headerColor,
    Color? buttonColor,
  }) {
    var canPressOk = true;
    return WidgetsBinding.instance.addPostFrameCallback((_) {
      showGeneralDialog(
          barrierColor: Colors.black,
          transitionBuilder: (context, a1, a2, widget) {
            return StatefulBuilder(builder: (context, setState) {
              return Transform.scale(
                scale: a1.value,
                child: Opacity(
                  opacity: a1.value,
                  child: PopScope(
                    canPop: false, // Prevents the pop action
                    onPopInvokedWithResult: (didPop, result) {
                      if (!didPop) {
                        // Perform any additional actions before pop occurs, if needed
                        Navigator.pop(context); // You can still manually trigger the pop here.
                      }
                    },
                    child: SafeArea(
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: (fullScreenWidget != null)
                              ? Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Container(
                                    decoration: BoxDecoration(color: AppColor.bgColor, borderRadius: const BorderRadius.all(Radius.circular(20)), border: Border.all(color: AppColor.greyLight)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Visibility(
                                            visible: title != null,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(title.toString(), style: MyTextTheme().mediumBCB),
                                                      Visibility(visible: subTitle != null, child: Text(subTitle.toString(), style: MyTextTheme().mediumGCB)),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      if (canPressOk) {
                                                        canPressOk = false;
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    icon: const Icon(Icons.clear, color: Colors.black))
                                              ],
                                            ),
                                          ),
                                          ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: fullScreenWidget),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : TabResponsive().wrapInTab(
                                  context: context,
                                  child: newWidget == null
                                      ? Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                                                child: Container(
                                                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                            decoration: BoxDecoration(
                                                                color: headerColor ?? AppColor.primaryColor,
                                                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Row(
                                                                children: [
                                                                  Visibility(
                                                                    visible: !(hideIcon ?? false),
                                                                    child: Icon(checkIcon ?? false ? Icons.check : Icons.info_outline, color: Colors.white),
                                                                  ),
                                                                  const SizedBox(width: 5),
                                                                  Expanded(
                                                                    child: Text(alert.toString(),
                                                                        textAlign: (centerTitle ?? false) ? TextAlign.center : TextAlign.start,
                                                                        style: const TextStyle(color: Colors.white, fontSize: 15)),
                                                                  ),
                                                                  const SizedBox(width: 5),
                                                                ],
                                                              ),
                                                            )),
                                                        Padding(
                                                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.all(8.0),
                                                                child: Text(msg.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    Visibility(
                                                                      visible: showCancelButton ?? false,
                                                                      child: TextButton(
                                                                        style: TextButton.styleFrom(foregroundColor: Colors.black, padding: const EdgeInsets.all(8)),
                                                                        onPressed: () {
                                                                          if (canPressOk) {
                                                                            canPressOk = false;
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        child: Text('Cancel', style: TextStyle(color: buttonColor ?? AppColor.primaryColor, fontWeight: FontWeight.bold)),
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible: secondButtonName != null,
                                                                      child: TextButton(
                                                                        style: TextButton.styleFrom(foregroundColor: Colors.black, padding: const EdgeInsets.all(8)),
                                                                        onPressed: () {
                                                                          if (canPressOk) {
                                                                            canPressOk = false;
                                                                            secondButtonPressEvent!();
                                                                          }
                                                                        },
                                                                        child: Text(secondButtonName.toString(),
                                                                            style: TextStyle(color: buttonColor ?? AppColor.primaryColor, fontWeight: FontWeight.bold)),
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible: firstButtonName != null,
                                                                      child: TextButton(
                                                                        style: TextButton.styleFrom(foregroundColor: Colors.black, padding: const EdgeInsets.all(8)),
                                                                        onPressed: () {
                                                                          if (canPressOk) {
                                                                            canPressOk = false;
                                                                            firstButtonPressEvent!();
                                                                          }
                                                                        },
                                                                        child:
                                                                            Text(firstButtonName.toString(), style: TextStyle(color: buttonColor ?? AppColor.primaryColor, fontWeight: FontWeight.bold)),
                                                                      ),
                                                                    ),
                                                                    Visibility(
                                                                      visible: showOkButton ?? true,
                                                                      child: TextButton(
                                                                        style: TextButton.styleFrom(foregroundColor: Colors.black, padding: const EdgeInsets.all(8)),
                                                                        onPressed: () {
                                                                          if (canPressOk) {
                                                                            canPressOk = false;
                                                                            Navigator.pop(context);
                                                                          }
                                                                        },
                                                                        child: Text('Ok', style: TextStyle(color: buttonColor ?? AppColor.primaryColor, fontWeight: FontWeight.bold)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(color: AppColor.bgColor, borderRadius: const BorderRadius.all(Radius.circular(20)), border: Border.all(color: AppColor.greyLight)),
                                          child: newWidget),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
          },
          transitionDuration: const Duration(milliseconds: 200),
          barrierDismissible: true,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          }).then((val) {
        canPressOk = false;
      });
    });
  }
}

class AlertDialogueManikin {
  show(
    context, {
    String? alert,
    String? msg,
    String? firstButtonName,
    Function? firstButtonPressEvent,
    String? secondButtonName,
    Function? secondButtonPressEvent,
    bool? showCancelButton,
    bool? showOkButton,
    bool? disableDuration,
    bool? checkIcon,
    bool? hideIcon,
    bool? centerTitle,
    Widget? newWidget,
    List<Widget>? fullScreenWidget,
    String? title,
    String? subTitle,
    Color? headerColor,
    Color? buttonColor,
    Color? bgColor,
    Color? firstButtonColor,
    Color? secondButtonColor,
    TextStyle? msgTextStyle,
  }) {
    var canPressOk = true;
    return WidgetsBinding.instance.addPostFrameCallback((_) {
      showGeneralDialog(
          barrierColor: Colors.black,
          transitionBuilder: (context, a1, a2, widget) {
            return StatefulBuilder(builder: (context, setState) {
              return Transform.scale(
                scale: a1.value,
                child: Opacity(
                  opacity: a1.value,
                  child: PopScope(
                    canPop: true, // Prevents the pop action
                    onPopInvokedWithResult: (didPop, result) {
                      if (!didPop) {
                        // Perform any additional actions before pop occurs, if needed
                      }
                    },
                    child: SafeArea(
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: (fullScreenWidget != null)
                              ? Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Container(
                                    decoration: BoxDecoration(color: AppColor.bgColor, borderRadius: const BorderRadius.all(Radius.circular(20)), border: Border.all(color: AppColor.greyLight)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Visibility(
                                            visible: title != null,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(title.toString(), style: MyTextTheme().mediumBCB),
                                                      Visibility(visible: subTitle != null, child: Text(subTitle.toString(), style: MyTextTheme().mediumGCB)),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      if (canPressOk) {
                                                        canPressOk = false;
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    icon: const Icon(Icons.clear, color: Colors.black))
                                              ],
                                            ),
                                          ),
                                          ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: fullScreenWidget),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : TabResponsive().wrapInTab(
                                  context: context,
                                  child: newWidget == null
                                      ? Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                        decoration: BoxDecoration(
                                                            color: bgColor ?? Colors.deepPurple, border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.all(Radius.circular(50))),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 30.0),
                                                                      child: Text(msg ?? '', textAlign: TextAlign.center, style: msgTextStyle ?? TextStyle(fontWeight: FontWeight.bold)))
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                    SizedBox(height: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                          secondButtonName != null && SizerUtil.deviceType == DeviceType.mobile ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(color: Colors.transparent),
                                                          child: Center(
                                                            child: Visibility(
                                                              visible: firstButtonName != null,
                                                              child: Container(
                                                                // width: 126,
                                                                height: 4.h,
                                                                decoration: BoxDecoration(
                                                                    color: firstButtonColor ?? Colors.deepPurple, borderRadius: BorderRadius.circular(19), border: Border.all(color: Colors.white)),
                                                                child: MaterialButton(
                                                                  onPressed: () {
                                                                    if (canPressOk) {
                                                                      canPressOk = false;
                                                                      firstButtonPressEvent!();
                                                                    }
                                                                  },
                                                                  child: Text(
                                                                    firstButtonName.toString(),
                                                                    style: TextStyle(color: buttonColor ?? AppColor.primaryColor, fontWeight: FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizerUtil.deviceType == DeviceType.mobile ? SizedBox() : SizedBox(width: 50),
                                                        Container(
                                                          decoration: BoxDecoration(color: Colors.transparent),
                                                          child: Visibility(
                                                            visible: secondButtonName != null,
                                                            child: Container(
                                                              // width: 126,
                                                              height: 4.h,
                                                              decoration: BoxDecoration(
                                                                  color: secondButtonColor ?? Colors.deepPurple, borderRadius: BorderRadius.circular(19), border: Border.all(color: Colors.white)),
                                                              child: MaterialButton(
                                                                onPressed: () {
                                                                  if (canPressOk) {
                                                                    canPressOk = false;
                                                                    secondButtonPressEvent!();
                                                                  }
                                                                },
                                                                child: Text(secondButtonName.toString(), style: TextStyle(color: buttonColor ?? AppColor.primaryColor, fontWeight: FontWeight.bold)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(color: AppColor.bgColor, borderRadius: const BorderRadius.all(Radius.circular(20)), border: Border.all(color: AppColor.greyLight)),
                                          child: newWidget),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
          },
          transitionDuration: const Duration(milliseconds: 200),
          barrierDismissible: true,
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Container();
          }).then((val) {
        canPressOk = false;
      });
    });
  }
}
