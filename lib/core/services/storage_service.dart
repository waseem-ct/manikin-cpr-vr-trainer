import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] so the rest of the app never touches the plugin directly.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async => StorageService(await SharedPreferences.getInstance());

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
}
