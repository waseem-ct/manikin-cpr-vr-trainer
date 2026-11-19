import 'package:get/get.dart';

import '../../../games/cardiopulmonary_resuscitation_module/cardiopulmonary_resuscitation_controller.dart';

class CardiopulmonaryResuscitationBinding extends Bindings {
  @override
  void dependencies() {
    // TODO: implement dependencies
    // Get.lazyPut<AccountsController>(()=>AccountsController());
    Get.put(CardiopulmonaryResuscitationController());
  }
}
