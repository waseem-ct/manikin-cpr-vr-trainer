import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../routing/route_names.dart';
import '../services/base_controller.dart';

class SplashController extends BaseController {
  
  @override
  void onInit() {
    super.onInit();
    _get();
  }

  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    //installerStore: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    packageInfo = info;
    update();
  }

  _get() async {
    _initPackageInfo();

    Future.delayed(const Duration(milliseconds: 4500), () {
      replaceRoute(RoutesNamed.home);
      // // Updater.checkVersion(Get.context);
      // if (UserData().getUserData.isNotEmpty) {
      //   replaceRoute(RoutesNamed.home);
      // } else {
      //   replaceRoute(RoutesNamed.login);
      // }
    });
  }

}
