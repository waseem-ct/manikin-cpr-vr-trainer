import 'package:get/get.dart';
import '../../home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    // Get.lazyPut<AccountsController>(()=>AccountsController());
    Get.put(HomeController());
  }
}
