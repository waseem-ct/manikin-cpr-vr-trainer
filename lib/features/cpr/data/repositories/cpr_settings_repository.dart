import '../../../../core/services/storage_service.dart';
import '../../domain/entities/cpr_settings.dart';
import '../../domain/entities/cpr_type.dart';

/// Saves / loads the dashboard options so they survive app restarts.
class CprSettingsRepository {
  CprSettingsRepository(this._storage);

  final StorageService _storage;

  static const _typeKey = 'cpr_type';
  static const _airBlowKey = 'cpr_with_air_blow';

  CprSettings load() => CprSettings(type: CprType.fromStorage(_storage.getString(_typeKey)), withAirBlow: _storage.getBool(_airBlowKey) ?? true);

  Future<void> save(CprSettings settings) async {
    await _storage.setString(_typeKey, settings.type.storageValue);
    await _storage.setBool(_airBlowKey, settings.withAirBlow);
  }
}
