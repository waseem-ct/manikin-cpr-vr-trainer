import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';

import 'new_global_module/routing/get_pages.dart';


class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // HttpOverrides.global = DevHttpOverrides();
  print("_start-------------------------------------------->>>");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Sizer(builder: (context, orientation, deviceType) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        return GetMaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            onInit: () async => await GetStorage.init('user'),
            defaultTransition: GetPageRoutes.leftToRight,
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            getPages: GetPageRoutes.routes,
            initialRoute: GetPageRoutes.INITIAL);
      });
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
