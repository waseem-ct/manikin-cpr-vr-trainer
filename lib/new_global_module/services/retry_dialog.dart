import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manikin_simulator/AppManager/app_color.dart';
import 'package:manikin_simulator/AppManager/my_text_theme.dart';

enum RetryDialogResult { retry, cancel }

class RetryDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? leadingButtonText;
  final String? trailingButtonText;
  final bool? isGradientDialog;
  final bool showCancel;
  final bool canPop;
  final int? autoRetrySeconds;
  final void Function()? onPressedLeading;
  final void Function()? onPressedTrailing;

  const RetryDialog(
      {super.key,
      required this.title,
      required this.message,
      this.showCancel = true,
      this.canPop = true,
      this.autoRetrySeconds,
      this.onPressedLeading,
      this.onPressedTrailing,
      this.leadingButtonText,
      this.trailingButtonText,
      this.isGradientDialog});

  @override
  State<RetryDialog> createState() => _RetryDialogState();

  /// Use this static method to show the dialog and get the result.
  static Future<RetryDialogResult?> showDefaultDialog(BuildContext context,
      {required String title,
      required String message,
      bool showCancel = true,
      bool canPop = true,
      int? autoRetrySeconds,
      String? leadingButtonText = 'Cancel',
      String? trailingButtonText = 'Retry Now',
      void Function()? onPressedLeading,
      void Function()? onPressedTrailing}) {
    return showDialog<RetryDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RetryDialog(
        title: title,
        message: message,
        canPop: canPop,
        showCancel: showCancel,
        autoRetrySeconds: autoRetrySeconds,
        leadingButtonText: leadingButtonText,
        trailingButtonText: trailingButtonText,
        onPressedLeading: onPressedLeading,
        onPressedTrailing: onPressedTrailing,
        isGradientDialog: false,
      ),
    );
  }

  static Future<RetryDialogResult?> showGradientDialog(BuildContext context,
      {required String title,
      required String message,
      bool showCancel = true,
      bool canPop = true,
      int? autoRetrySeconds,
      String? leadingButtonText = 'Cancel',
      String? trailingButtonText = 'Retry Now',
      void Function()? onPressedLeading,
      void Function()? onPressedTrailing}) {
    return showDialog<RetryDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RetryDialog(
        title: title,
        message: message,
        canPop: canPop,
        showCancel: showCancel,
        autoRetrySeconds: autoRetrySeconds,
        leadingButtonText: leadingButtonText,
        trailingButtonText: trailingButtonText,
        onPressedLeading: onPressedLeading,
        isGradientDialog: true,
        onPressedTrailing: onPressedTrailing,
      ),
    );
  }
}

class _RetryDialogState extends State<RetryDialog> {
  Timer? _timer;
  int? _remaining;
  Gradient buttonColor = LinearGradient(colors: [Color(0xFFF66524), Color(0xFFF8A52B)], begin: Alignment.topLeft, end: Alignment.bottomRight);
  TextStyle _textStyle = MyTextTheme().largeWCN.copyWith();
  ButtonStyle _buttonStyle = OutlinedButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: AppColor.white,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
      padding: EdgeInsets.symmetric(horizontal: 15),
      side: BorderSide(color: AppColor.white, width: 0.8));

  @override
  void initState() {
    super.initState();
    if (widget.autoRetrySeconds != null && widget.autoRetrySeconds! > 0) {
      _remaining = widget.autoRetrySeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remaining != null && _remaining! > 0) {
          setState(() => _remaining = _remaining! - 1);
        } else {
          _timer?.cancel();
          Navigator.of(context, rootNavigator: true).pop(RetryDialogResult.retry);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canPop,
      child: Dialog(
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: widget.isGradientDialog == true ? const LinearGradient(colors: [Color(0xFF643CF8), Color(0xFF4B73F1)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: AppColor.proPurple,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColor.white, width: 3),
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.title.isEmpty ? SizedBox() : Text(widget.title, textAlign: TextAlign.center, style: widget.isGradientDialog == true ? MyTextTheme().largeWCN : MyTextTheme().largeWCB),
                  Text(widget.message, textAlign: TextAlign.center, style: MyTextTheme().largeWCN),
                  if (_remaining != null && _remaining! > 0) ...[
                    const SizedBox(height: 12),
                    Text("Retrying in $_remaining seconds...", style: MyTextTheme().mediumPCN),
                  ],
                  if (!widget.showCancel) const SizedBox(height: 10),
                  if (widget.isGradientDialog == false)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (widget.showCancel)
                          OutlinedButton(
                              style: _buttonStyle,
                              onPressed: widget.onPressedLeading ?? () => Navigator.of(context).pop(RetryDialogResult.cancel),
                              child: Text(widget.leadingButtonText ?? 'Cancel', style: _textStyle)),
                        OutlinedButton(
                            style: _buttonStyle,
                            onPressed: widget.onPressedTrailing ?? () => Navigator.of(context).pop(RetryDialogResult.retry),
                            child: Text(widget.trailingButtonText ?? 'Retry Now', style: _textStyle)),
                      ],
                    ),
                ],
              ),
            ),
            if (widget.isGradientDialog == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.showCancel)
                    _buildGradientButton(text: widget.leadingButtonText ?? 'Cancel', onPressed: widget.onPressedLeading ?? () => Navigator.of(context).pop(RetryDialogResult.cancel)),
                  _buildGradientButton(text: widget.trailingButtonText ?? 'Retry Now', onPressed: widget.onPressedTrailing ?? () => Navigator.of(context).pop(RetryDialogResult.retry)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(gradient: buttonColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColor.white)),
      child: InkWell(onTap: onPressed, child: Text(text, style: MyTextTheme().largeWCN)),
    );
  }
}
