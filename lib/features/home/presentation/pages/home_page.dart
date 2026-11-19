import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../cpr/domain/entities/cpr_type.dart';
import '../providers/home_provider.dart';
import '../widgets/manikin_type_dropdown.dart';

/// Dashboard: pick the manikin type, then Play.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) provider.confirmExit();
      },
      child: AppScaffold(
        child: SingleChildScrollView(
          child: Column(
            spacing: 16,
            children: [
              const SizedBox(height: 10),
              Selector<HomeProvider, CprType>(
                selector: (_, p) => p.type,
                builder: (_, type, __) => ManikinTypeDropdown(value: type, onChanged: provider.changeType),
              ),
              const _ManikinImage(),
              GradientButton(width: context.screenWidth * 0.7, title: 'Play', onTap: provider.play),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManikinImage extends StatelessWidget {
  const _ManikinImage();

  @override
  Widget build(BuildContext context) {
    final type = context.select<HomeProvider, CprType>((p) => p.type);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.cardSoft),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Image.asset(type.image, key: ValueKey(type), height: context.screenHeight * 0.42),
      ),
    );
  }
}
