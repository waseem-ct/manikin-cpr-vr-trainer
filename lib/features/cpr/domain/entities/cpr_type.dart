import '../../../../core/constants/app_constants.dart';
import 'cpr_layout.dart';

/// The manikin variants the app supports.
enum CprType {
  adult(
    storageValue: 'AdultCPR',
    label: 'Adult CPR',
    layout: CprLayout(
      image: AppAssets.manikinAdult,
      gap: 0.22,
      leftDotTop: 0.65,
      leftDotRight: 0.0,
      leftDotLeft: 0.25,
      rightDotTop: 0.65,
      rightDotRight: 0.25,
      rightDotLeft: 0.0,
      centerDotTop: 0.62,
      centerDotRight: 1.0,
      centerDotLeft: 0.0,
    ),
  ),
  child(
    storageValue: 'ChildCPR',
    label: 'Child CPR',
    layout: CprLayout(
      image: AppAssets.manikinChild,
      gap: 0.05,
      leftDotTop: 0.25,
      leftDotRight: 0.0,
      leftDotLeft: 0.1,
      rightDotTop: 0.25,
      rightDotRight: 0.1,
      rightDotLeft: 0.0,
      centerDotTop: 0.25,
      centerDotRight: 0.2,
      centerDotLeft: 0.0,
    ),
  ),
  neonatal(
    storageValue: 'NeonatalCPR',
    label: 'Neonatal CPR',
    layout: CprLayout(
      image: AppAssets.manikinNeonatal,
      gap: 0.05,
      leftDotTop: 0.33,
      leftDotRight: 0.0,
      leftDotLeft: 0.1,
      rightDotTop: 0.33,
      rightDotRight: 0.1,
      rightDotLeft: 0.0,
      centerDotTop: 0.34,
      centerDotRight: 0.2,
      centerDotLeft: 0.0,
    ),
  );

  const CprType({required this.storageValue, required this.label, required this.layout});

  final String storageValue;
  final String label;
  final CprLayout layout;

  String get image => layout.image;

  static CprType fromStorage(String? value) => CprType.values.firstWhere((t) => t.storageValue == value, orElse: () => CprType.adult);
}
