import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/bluetooth/presentation/pages/bluetooth_devices_page.dart';
import '../../features/bluetooth/presentation/providers/bluetooth_provider.dart';
import '../../features/cpr/presentation/pages/cpr_page.dart';
import '../../features/cpr/presentation/providers/cpr_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/splash/presentation/providers/splash_provider.dart';
import '../di/injection.dart';
import '../services/navigation_service.dart';
import 'app_routes.dart';

/// Route table. Feature providers are created here (from the DI container) so pages stay free of DI code.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    initialLocation: AppRoutes.splashPath,
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => ChangeNotifierProvider(lazy: false, create: (_) => di<SplashProvider>()..start(), child: const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => ChangeNotifierProvider(lazy: false, create: (_) => di<HomeProvider>(), child: const HomePage()),
      ),
      GoRoute(
        path: AppRoutes.bluetoothPath,
        name: AppRoutes.bluetooth,
        builder: (context, state) => ChangeNotifierProvider(lazy: false, create: (_) => di<BluetoothProvider>()..initialize(), child: const BluetoothDevicesPage()),
      ),
      GoRoute(
        path: AppRoutes.cprPath,
        name: AppRoutes.cpr,
        redirect: (context, state) => state.extra is BluetoothDevice ? null : AppRoutes.homePath,
        builder: (context, state) {
          final device = state.extra as BluetoothDevice;
          return ChangeNotifierProvider(lazy: false, create: (_) => di<CprProvider>(param1: device)..start(), child: const CprPage());
        },
      ),
    ],
  );
}
