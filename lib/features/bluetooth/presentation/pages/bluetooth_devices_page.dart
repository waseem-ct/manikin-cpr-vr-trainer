import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/entities/ble_device_item.dart';
import '../providers/bluetooth_provider.dart';
import '../widgets/bluetooth_off_view.dart';
import '../widgets/bluetooth_scanning_view.dart';
import '../widgets/device_tile.dart';
import '../widgets/scan_button.dart';

/// Lists nearby Bluetooth devices (manikins first). Tapping Connect opens the CPR game.
class BluetoothDevicesPage extends StatelessWidget {
  const BluetoothDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isOn = context.select<BluetoothProvider, bool>((p) => p.isAdapterOn);
    if (!isOn) {
      final state = context.select<BluetoothProvider, BluetoothAdapterState>((p) => p.adapterState);
      return BluetoothOffView(state: state, onTurnOn: context.read<BluetoothProvider>().turnOnBluetooth);
    }
    return AppScaffold(
      floatingActionButton: const ScanButton(),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppHeader(
                  margin: EdgeInsets.zero,
                  title: 'My Devices',
                  onBack: context.read<BluetoothProvider>().goBack,
                  trailingColor: AppColors.purple,
                  trailingIcon: const Icon(Icons.bluetooth_outlined, color: Colors.white, size: 30),
                  onTrailingTap: context.read<BluetoothProvider>().openBluetoothSettings,
                ),
                const Expanded(child: _DeviceList()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList();

  @override
  Widget build(BuildContext context) {
    final devices = context.select<BluetoothProvider, List<BleDeviceItem>>((p) => p.devices);
    final isScanning = context.select<BluetoothProvider, bool>((p) => p.isScanning);
    final provider = context.read<BluetoothProvider>();

    if (isScanning && devices.isEmpty) return const BluetoothScanningView();

    final decoration = BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(30));
    if (devices.isEmpty) {
      return Container(
        alignment: Alignment.center,
        decoration: decoration,
        padding: const EdgeInsets.all(20),
        child: Text('No devices found.\nSwitch the manikin on, allow the Nearby devices permission, and tap the refresh button.',
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
      );
    }
    return Container(
      decoration: decoration,
      child: RefreshIndicator(
        onRefresh: provider.scan,
        color: Colors.white,
        backgroundColor: AppColors.purple,
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: devices.length,
          itemBuilder: (context, index) => DeviceTile(item: devices[index], onConnect: () => provider.connect(devices[index].device)),
        ),
      ),
    );
  }
}
