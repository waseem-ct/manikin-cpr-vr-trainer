import 'package:flutter/foundation.dart';

import '../../../AppManager/user_data.dart';

/// Single source of truth for the VR server address.
///
/// This app only talks to the VR server (it has no login and no other API), so the base URL lives here and is the
/// only place that needs changing. A temporary override can be stored with [UserData.addTempBaseUrl].
class VRApiService {
  /// VR server base URL (no trailing slash).
  static const String defaultBaseUrl = "https://manikinapi.trueformgames.com:5180/api";

  static const String eventEndPoint = "/VrEvent";

  static String get baseUrl {
    try {
      final stored = UserData().getTempBaseUrl;
      if (stored.trim().isNotEmpty) return stored.trim().replaceAll(RegExp(r'/+$'), '');
    } catch (e) {
      debugPrint('VRApiService: could not read stored base url ($e)');
    }
    return defaultBaseUrl;
  }

  /// Full URL live CPR events are POSTed to.
  static String get eventUrl => '$baseUrl$eventEndPoint';
}
