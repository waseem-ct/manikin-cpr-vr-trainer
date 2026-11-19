import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service.dart';

/// Waits a moment on the logo, then opens the dashboard.
class SplashProvider extends ChangeNotifier {
  SplashProvider(this._navigation);

  final NavigationService _navigation;
  bool _isDisposed = false;

  Future<void> start() async {
    await Future.delayed(AppConstants.splashDuration);
    if (!_isDisposed) _navigation.goToHome();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
