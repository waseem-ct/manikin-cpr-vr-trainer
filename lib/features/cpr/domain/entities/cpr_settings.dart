import 'cpr_type.dart';

/// Options chosen on the dashboard.
class CprSettings {
  const CprSettings({this.type = CprType.adult, this.withAirBlow = true});

  final CprType type;

  /// True: rescue breaths must be blown into the manikin. False: the step is only shown as a prompt.
  final bool withAirBlow;

  CprSettings copyWith({CprType? type, bool? withAirBlow}) => CprSettings(type: type ?? this.type, withAirBlow: withAirBlow ?? this.withAirBlow);
}
