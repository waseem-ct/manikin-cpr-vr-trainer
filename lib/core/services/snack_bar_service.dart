import 'package:flutter/material.dart';

/// Short messages ("device connected", "reconnection failed", ...).
class SnackBarService {
  /// Attached to `MaterialApp.router`, so messages can be shown without a `BuildContext`.
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  void show(String message) {
    messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }
}
