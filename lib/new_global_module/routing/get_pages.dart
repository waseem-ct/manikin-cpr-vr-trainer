import 'package:get/get.dart';
import 'package:manikin_simulator/new_global_module/routing/route_names.dart';

import '../../games/cardiopulmonary_resuscitation_module/cardiopulmonary_resuscitation_view.dart';
import '../Splash/splash_view.dart';
import '../bindings/Games/cardiopulmonary_resuscitation.dart';
import '../bindings/HomePage/home.dart';
import '../bindings/SplashScreen/splash.dart';
import '../bindings/bluetooth/bluetooth_bindings.dart';
import '../bluetooth_connectivity/bluetooth_devices_view.dart';
import '../home/home_page.dart';

/// Flow: Splash -> Home (dashboard) -> Bluetooth devices -> CPR game.
class GetPageRoutes {
  static const INITIAL = RoutesNamed.root;
  static const leftToRight = Transition.cupertinoDialog;
  static final routes = [
    GetPage(name: RoutesNamed.root, page: () => SplashScreen(), transition: leftToRight, binding: SplashBinding()),
    GetPage(name: RoutesNamed.home, page: () => const HomePage(), transition: leftToRight, binding: HomeBinding()),
    GetPage(name: RoutesNamed.bluetoothDevices, page: () => const BluetoothDevicesView(), transition: leftToRight, binding: BluetoothDevicesBinding()),
    GetPage(name: RoutesNamed.cardiopulmonaryResuscitation, page: () => CardiopulmonaryResuscitationView(), transition: leftToRight, binding: CardiopulmonaryResuscitationBinding()),
  ];
}
