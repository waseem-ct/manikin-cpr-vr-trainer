import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_routes.dart';

/// All navigation goes through here, so providers and services never need a `BuildContext`.
class NavigationService {
  /// Root navigator of the router; also used by [DialogService] and [SnackBarService].
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// A context that sits *below* the root navigator (safe for dialogs, sheets and `GoRouter.of`).
  static BuildContext? get context => navigatorKey.currentState?.overlay?.context;

  GoRouter? get _router {
    final ctx = context;
    return ctx == null ? null : GoRouter.of(ctx);
  }

  void goToHome() => _router?.goNamed(AppRoutes.home);
  void goToBluetooth() => _router?.pushNamed(AppRoutes.bluetooth);

  /// Replaces the device list with the game screen for [device].
  void replaceWithCpr(BluetoothDevice device) => _router?.pushReplacementNamed(AppRoutes.cpr, extra: device);

  void back() {
    final router = _router;
    if (router != null && router.canPop()) router.pop();
  }
}
