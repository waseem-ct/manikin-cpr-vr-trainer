import 'package:get/get.dart';
import '../../bluetooth_connectivity/bluetooth_devices_controller.dart';

class BluetoothDevicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BluetoothDevicesController());

  }
}
