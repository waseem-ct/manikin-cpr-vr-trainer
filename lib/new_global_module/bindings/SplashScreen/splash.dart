import 'package:get/get.dart';

import '../../Splash/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    // Get.lazyPut<AccountsController>(()=>AccountsController());
    Get.put(SplashController());
  }
}
