import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_it/get_it.dart';

import '../../features/bluetooth/data/services/ble_service.dart';
import '../../features/bluetooth/presentation/providers/bluetooth_provider.dart';
import '../../features/cpr/data/repositories/cpr_settings_repository.dart';
import '../../features/cpr/data/services/network_monitor_service.dart';
import '../../features/cpr/data/services/vr_event_service.dart';
import '../../features/cpr/presentation/providers/cpr_provider.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/splash/presentation/providers/splash_provider.dart';
import '../services/dialog_service.dart';
import '../services/navigation_service.dart';
import '../services/snack_bar_service.dart';
import '../services/storage_service.dart';

/// Global service locator. Usage: `di<BleService>()`.
final GetIt di = GetIt.instance;

/// Registers every service (singletons) and provider (a new instance per screen).
Future<void> configureDependencies() async {
  // ── Core services (one instance for the whole app) ──
  di.registerSingleton<StorageService>(await StorageService.create());
  di.registerLazySingleton<NavigationService>(NavigationService.new);
  di.registerLazySingleton<DialogService>(DialogService.new);
  di.registerLazySingleton<SnackBarService>(SnackBarService.new);

  // ── Feature services / repositories ──
  di.registerLazySingleton<BleService>(BleService.new);
  di.registerLazySingleton<VrEventService>(VrEventService.new);
  di.registerLazySingleton<CprSettingsRepository>(() => CprSettingsRepository(di<StorageService>()));
  di.registerFactory<NetworkMonitorService>(NetworkMonitorService.new); // one per game session

  // ── Providers (a fresh one each time its screen opens) ──
  di.registerFactory<SplashProvider>(() => SplashProvider(di<NavigationService>()));
  di.registerFactory<HomeProvider>(() => HomeProvider(di<CprSettingsRepository>(), di<NavigationService>(), di<DialogService>()));
  di.registerFactory<BluetoothProvider>(() => BluetoothProvider(di<BleService>(), di<NavigationService>(), di<DialogService>(), di<SnackBarService>()));
  di.registerFactoryParam<CprProvider, BluetoothDevice, void>(
    (device, _) => CprProvider(device, di<BleService>(), di<VrEventService>(), di<NetworkMonitorService>(), di<CprSettingsRepository>(), di<NavigationService>(), di<DialogService>(), di<SnackBarService>()),
  );
}
