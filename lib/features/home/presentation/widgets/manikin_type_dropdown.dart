import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cpr/domain/entities/cpr_type.dart';

/// Dropdown to pick Adult / Child / Neonatal CPR.
class ManikinTypeDropdown extends StatelessWidget {
  const ManikinTypeDropdown({super.key, required this.value, required this.onChanged});

  final CprType value;
  final ValueChanged<CprType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CprType>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.purple),
          style: AppTextStyles.purpleMedium,
          items: [for (final type in CprType.values) DropdownMenuItem(value: type, child: Text(type.label))],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
