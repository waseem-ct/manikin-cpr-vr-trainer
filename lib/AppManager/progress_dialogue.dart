import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../App_Constant/app_constant.dart';
import 'my_text_theme.dart';

late BuildContext currentContext;

class ProgressDialogue {
  show(context, {required String loadingText}) async => showProgressDialogue(context, loadingText);

  hide() async {
    try {
      Navigator.pop(currentContext);
    } catch (e) {
      print(e);
    }
  }
}

showProgressDialogue(context, loadingText) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      currentContext = dialogContext;
      return PopScope(
        canPop: false,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(padding: const EdgeInsets.all(10.0), child: SizedBox(height: 70, child: Lottie.asset(AppConstant.apiLoaderAnimation))),
                        Text(loadingText ?? 'Default', style: MyTextTheme().mediumWCB),
                        // factsDialogue(),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      );
    },
  );
}
