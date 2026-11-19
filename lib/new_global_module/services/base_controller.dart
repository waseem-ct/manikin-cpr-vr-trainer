import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:manikin_simulator/AppManager/user_data.dart';

import '../new_widgets/services/navigation_services.dart';
abstract class BaseController extends GetxController with NavigationService {
  StreamSubscription<BluetoothConnectionState>? connectionSubscription;
  final ValueNotifier<bool> _isConnected = ValueNotifier(true);
  UserData userData = UserData();
  ValueNotifier<bool> get isConnected => _isConnected;
  set setIsConnected(value) {
    _isConnected.value = value;
  }

  final RxBool _loadingData = false.obs;
  bool get loadingData => _loadingData.value;

  void setLoadingState(bool loading) {
    _loadingData.value = loading;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void showMessage({String title = "Error", required String message}) {
    Get.showSnackbar(GetSnackBar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
    ));
  }
}

abstract class BasePage<T extends BaseController> extends GetView<T> {
  const BasePage({super.key});
}
