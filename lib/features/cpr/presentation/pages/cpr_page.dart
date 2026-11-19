import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/entities/cpr_sensor_data.dart';
import '../providers/cpr_provider.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/cpr_app_bar.dart';
import '../widgets/manikin_stage.dart';
import '../widgets/pressure_gauge.dart';

/// The CPR game screen.
class CprPage extends StatelessWidget {
  const CprPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CprProvider>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) provider.confirmExit();
      },
      child: const AppScaffold(keepScreenOn: true, bottomNavigationBar: _GaugeBar(), child: _Body()),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CprProvider>();
    return Column(
      children: [
        const CprAppBar(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              return FittedBox(
                fit: BoxFit.fitHeight,
                child: Column(
                  children: [
                    if (context.isTablet) SizedBox(height: height * 0.02),
                    const _Timer(),
                    SizedBox(height: height * 0.02),
                    Selector<CprProvider, CprSensorData>(
                      selector: (_, p) => p.sensor,
                      builder: (_, sensor, __) => ManikinStage(layout: provider.layout, sensor: sensor, width: width, height: height),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Timer extends StatelessWidget {
  const _Timer();

  @override
  Widget build(BuildContext context) {
    final seconds = context.select<CprProvider, int>((p) => p.second);
    final attempt = context.select<CprProvider, int>((p) => p.attempt);
    return CountdownTimer(seconds: seconds, totalSeconds: CprProvider.sessionSeconds, attempt: attempt);
  }
}

class _GaugeBar extends StatelessWidget {
  const _GaugeBar();

  @override
  Widget build(BuildContext context) {
    final pressure = context.select<CprProvider, int>((p) => p.second == 0 ? 0 : p.sensor.pressure);
    final total = context.select<CprProvider, int>((p) => p.total);
    return PressureGauge(pressure: pressure, totalCount: total);
  }
}
