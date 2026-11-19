import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to the values in `.env` (see `.env.example`).
///
/// Every getter has a built-in default, so the app still starts if a key is missing from `.env`.
class AppEnv {
  AppEnv._();

  /// Loads `.env`. A missing file is not fatal: the defaults below are used instead.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      dotenv.loadFromString(envString: '');
    }
  }

  // ── VR server ──────────────────────────────────────────────────────────────
  static String get vrBaseUrl => _string('VR_BASE_URL', 'https://manikinapi.trueformgames.com:5180/api').replaceAll(RegExp(r'/+$'), '');
  static String get vrEventPath => _string('VR_EVENT_PATH', '/VrEvent');
  static String get vrEventUrl => '$vrBaseUrl$vrEventPath';
  static Duration get vrRequestTimeout => Duration(seconds: _int('VR_REQUEST_TIMEOUT_SECONDS', 5));
  static Duration get vrPingInterval => Duration(seconds: _int('VR_PING_INTERVAL_SECONDS', 3));

  // ── Manikin (BLE) ──────────────────────────────────────────────────────────
  static String get bleServiceUuid => _string('BLE_SERVICE_UUID', 'C201');
  static String get bleCharacteristicUuid => _string('BLE_CHARACTERISTIC_UUID', '483E');
  static String get bleDeviceNameKeyword => _string('BLE_DEVICE_NAME_KEYWORD', 'CT');

  static String _string(String key, String fallback) {
    final value = dotenv.maybeGet(key)?.trim();
    return (value == null || value.isEmpty) ? fallback : value;
  }

  static int _int(String key, int fallback) => int.tryParse(dotenv.maybeGet(key)?.trim() ?? '') ?? fallback;
}
