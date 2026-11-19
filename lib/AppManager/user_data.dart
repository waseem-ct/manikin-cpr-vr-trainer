import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../games/cardiopulmonary_resuscitation_module/SerivicesVr/api_serivce_for_vr.dart';

/// Local storage. Only holds an optional override of the VR server address.
class UserData extends GetxController with GetxServiceMixin {
  final userData = GetStorage('user');

  String get getTempBaseUrl => userData.read("tempBaseUrl") ?? VRApiService.defaultBaseUrl;
  addTempBaseUrl(String value) => userData.write("tempBaseUrl", value);
  removeTempBaseUrl() async => await userData.remove('tempBaseUrl');
}
