import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../App_Constant/app_constant.dart';
import 'my_text_theme.dart';


class BluetoothLostConnection {
  show(context, {required String msg, required String title, required Function onPressExit, required Function onPressRetry}) {
    return WidgetsBinding.instance.addPostFrameCallback((_) {
      showGeneralDialog(
          // barrierLabel:
          // MaterialLocalizations.of(context).modalBarrierDismissLabel,
          context: context,
          barrierDismissible: false,
          transitionDuration: const Duration(milliseconds: 200),
          transitionBuilder: (context, a1, a2, widget) {
            return Transform.scale(
              scale: a1.value,
              child: PopScope(
                canPop: false,
                child: Material(
                  color: Colors.transparent,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.white, width: 5), color: Colors.deepPurple),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(title.toString(), style: MyTextTheme().extraLargeWCB),
                                    const Icon(Icons.bluetooth, size: 100, color: Colors.white),
                                    const SizedBox(height: 8),
                                    Text(msg.toString(), textAlign: TextAlign.center, style: MyTextTheme().mediumWCN.copyWith(fontFamily: 'Poppins-Regular', fontSize: 13.sp)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(40),
                                    onTap: () => onPressExit(),
                                    child: const CircleAvatar(maxRadius: 40, backgroundColor: Color.fromRGBO(241, 116, 6, 1), child: Icon(Icons.arrow_back, size: 45, color: Colors.white)),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(40),
                                    onTap: () => onPressRetry(),
                                    child: const CircleAvatar(maxRadius: 40, backgroundColor: Colors.green, child: Icon(Icons.refresh, size: 45, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          pageBuilder: (context, animation1, animation2) {
            return Container();
          });
    });
  }
}

class BluetoothLostConnectionAlertGetX {
  Future<T?>? show<T>({Function? onPressExit, Function? onPressRetry}) {
    return Get.dialog<T>(
      PopScope(
        canPop: false,
        child: Material(
          color: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.white, width: 5), color: Colors.deepPurple),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('OOPS'.toString(), style: MyTextTheme().extraLargeWCB),
                            const Icon(Icons.bluetooth, size: 100, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(AppConstant.bleLostConnection.toString(), textAlign: TextAlign.center, style: MyTextTheme().mediumWCN.copyWith(fontFamily: 'Poppins-Regular', fontSize: 13.sp))
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => onPressExit?.call(),
                            child: const CircleAvatar(maxRadius: 40, backgroundColor: Color.fromRGBO(241, 116, 6, 1), child: Icon(Icons.arrow_back, size: 45, color: Colors.white)),
                          ),
                        ),
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => onPressRetry?.call(),
                            child: const CircleAvatar(maxRadius: 40, backgroundColor: Colors.green, child: Icon(Icons.refresh, size: 45, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      useSafeArea: true,
      // Must be answered with Exit / Retry; a tap outside would hide it while the connection is still lost.
      barrierDismissible: false,
    );
  }
}
