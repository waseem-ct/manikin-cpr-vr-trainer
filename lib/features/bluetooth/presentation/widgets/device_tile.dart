import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../domain/entities/ble_device_item.dart';
import 'signal_strength_bar.dart';

/// One row of the device list: icon, name, id + signal, and a Connect / Play button.
class DeviceTile extends StatelessWidget {
  const DeviceTile({super.key, required this.item, required this.onConnect});

  final BleDeviceItem item;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final isTab = context.isTablet;
    final device = item.device;
    final initial = device.isConnected ? BluetoothConnectionState.connected : BluetoothConnectionState.disconnected;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: isTab ? 12 : 8, horizontal: 4),
          child: StreamBuilder<BluetoothConnectionState>(
            stream: device.connectionState,
            initialData: initial,
            builder: (context, snapshot) {
              final connected = snapshot.data == BluetoothConnectionState.connected;
              return Row(
                spacing: isTab ? 16 : 10,
                children: [
                  _Avatar(isManikin: item.isManikin, isConnected: connected, radius: isTab ? 24 : 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.purpleMedium.copyWith(fontSize: isTab ? 15 : 13)),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(device.remoteId.toString(), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.grey, fontSize: isTab ? 11 : 9)),
                            if (item.rssi != null) SignalStrengthBar(rssi: item.rssi!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GradientButton(
                    width: isTab ? 150 : 96,
                    height: isTab ? 46 : 32,
                    elevation: 1,
                    onTap: onConnect,
                    title: connected ? 'Play' : 'Connect',
                    textStyle: AppTextStyles.whiteMediumBold.copyWith(fontSize: isTab ? 13 : 11),
                  ),
                ],
              );
            },
          ),
        ),
        const Divider(height: 3, color: Colors.white, thickness: 1),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.isManikin, required this.isConnected, required this.radius});

  final bool isManikin;
  final bool isConnected;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(backgroundColor: isManikin ? AppColors.purple : Colors.blueGrey, radius: radius, child: Icon(isManikin ? Icons.medical_services : Icons.bluetooth, color: Colors.white, size: radius)),
        if (isConnected) Positioned(bottom: -2, right: -2, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))),
      ],
    );
  }
}
