import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../cpr/data/repositories/cpr_settings_repository.dart';
import '../../../cpr/domain/entities/cpr_settings.dart';
import '../../../cpr/domain/entities/cpr_type.dart';

/// Dashboard state: the manikin type, the air-blow option, and the exit confirmation.
class HomeProvider extends ChangeNotifier {
  HomeProvider(this._repository, this._navigation, this._dialogs) : _settings = _repository.load();

  final CprSettingsRepository _repository;
  final NavigationService _navigation;
  final DialogService _dialogs;

  CprSettings _settings;

  CprType get type => _settings.type;

  void changeType(CprType? value) {
    if (value == null || value == _settings.type) return;
    _settings = _settings.copyWith(type: value);
    _repository.save(_settings);
    notifyListeners();
  }


  void play() => _navigation.goToBluetooth();

  /// Back button on the dashboard: ask before closing the app.
  Future<void> confirmExit() async {
    final exit = await _dialogs.show<bool>((_) => const ConfirmDialog(title: 'Are You Sure ?', message: 'Do You Want To Exit!'));
    if (exit == true) await SystemNavigator.pop();
  }
}
