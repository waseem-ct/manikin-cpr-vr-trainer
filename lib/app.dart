import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/services/snack_bar_service.dart';
import 'core/theme/app_theme.dart';

/// Root widget. Feature providers are created per route in [AppRouter], so nothing global is provided here.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      scaffoldMessengerKey: SnackBarService.messengerKey,
      routerConfig: AppRouter.router,
    );
  }
}
