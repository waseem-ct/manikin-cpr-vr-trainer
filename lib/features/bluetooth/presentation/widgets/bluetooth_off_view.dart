import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/gradient_button.dart';
import 'bluetooth_scanning_view.dart';

/// Full-screen "Bluetooth is off" state with a Turn On button.
class BluetoothOffView extends StatelessWidget {
  const BluetoothOffView({super.key, required this.state, required this.onTurnOn});

  final BluetoothAdapterState state;
  final Future<void> Function() onTurnOn;

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    return AppScaffold(
      backgroundColor: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: context.screenHeight / 3, width: 250, child: const BluetoothScanningView(iconSize: 200, rings: false)),
          const SizedBox(height: 25),
          Text('Bluetooth Adapter is ${state == BluetoothAdapterState.on ? "On" : "Off"}', style: AppTextStyles.whiteMediumBold.copyWith(fontSize: width / 28)),
          const SizedBox(height: 15),
          GradientButton(width: width / 3, backgroundColor: Colors.green, title: 'Turn On', textStyle: AppTextStyles.whiteMediumBold.copyWith(fontSize: width / 28), onTap: onTurnOn),
        ],
      ),
    );
  }
}
