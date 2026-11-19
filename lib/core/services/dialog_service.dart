import 'package:flutter/material.dart';

import '../widgets/progress_dialog.dart';
import 'navigation_service.dart';

/// Shows dialogs and bottom sheets from anywhere (providers, services) without a `BuildContext`.
class DialogService {
  bool _isProgressOpen = false;

  BuildContext? get _context => NavigationService.context;

  /// Shows a modal dialog that the user cannot dismiss by tapping outside.
  Future<T?> show<T>(WidgetBuilder builder, {bool barrierDismissible = false}) {
    final ctx = _context;
    if (ctx == null) return Future.value(null);
    return showDialog<T>(context: ctx, barrierDismissible: barrierDismissible, builder: builder);
  }

  /// Shows a modal bottom sheet.
  Future<T?> showSheet<T>(WidgetBuilder builder, {bool isDismissible = true}) {
    final ctx = _context;
    if (ctx == null) return Future.value(null);
    return showModalBottomSheet<T>(context: ctx, isDismissible: isDismissible, backgroundColor: Colors.transparent, builder: builder);
  }

  /// Closes the top-most dialog or sheet.
  void dismiss<T>([T? result]) {
    final ctx = _context;
    if (ctx != null && Navigator.of(ctx).canPop()) Navigator.of(ctx).pop(result);
  }

  /// Shows a blocking progress dialog. Calling it twice shows one dialog.
  void showProgress(String text) {
    if (_isProgressOpen) return;
    _isProgressOpen = true;
    show<void>((_) => ProgressDialog(text: text)).whenComplete(() => _isProgressOpen = false);
  }

  Future<void> hideProgress() async {
    if (!_isProgressOpen) return;
    _isProgressOpen = false;
    dismiss();
  }
}
