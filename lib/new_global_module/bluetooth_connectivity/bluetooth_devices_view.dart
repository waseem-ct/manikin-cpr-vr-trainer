import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:manikin_simulator/AppManager/manikin_header_buttons.dart';
import 'package:manikin_simulator/AppManager/widgets/custom_gradient_button.dart';
import 'package:manikin_simulator/new_global_module/bluetooth_connectivity/widgets/bluetooth_all_widgets.dart';
import 'package:sizer/sizer.dart';

import '../../AppManager/app_color.dart';
import '../../AppManager/my_text_theme.dart';
import '../../AppManager/progress_dialogue.dart';
import '../new_widgets/scaffold_widget.dart';
import 'bluetooth_devices_controller.dart';

/// Lists the nearby CT manikins. Tapping "Connect" connects and opens the CPR game.
class BluetoothDevicesView extends GetView<BluetoothDevicesController> {
  const BluetoothDevicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothAdapterState>(
        stream: FlutterBluePlus.adapterState,
        builder: (context, snapshot) {
          if (snapshot.data != BluetoothAdapterState.on) {
            return BluetoothStateAndScanWidget(state: snapshot.data ?? BluetoothAdapterState.unknown);
          }
          return MyScaffold(
              floatingActionButton: Obx(() => FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: () {
                    if (!controller.isScanning.value) controller.startScanDevices();
                  },
                  backgroundColor: Colors.orange,
                  tooltip: 'Scan',
                  child: SpinningIcon(iconData: Icons.refresh, isSpinning: controller.isScanning.value, color: Colors.white, size: 30))),
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
                            MyCustomHeaderButton(
                              containerMargin: EdgeInsets.zero,
                              centerText: "My Devices",
                              leadingTap: () => Get.back(),
                              trailingBackGroundColor: AppColor.proPurple,
                              trailingIcon: Icon(Icons.bluetooth_outlined, color: AppColor.white, fontWeight: FontWeight.w500, size: 20.sp),
                              trailingTap: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth),
                            ),
                            Expanded(
                                // Rebuilds on scan results AND on connect / disconnect, so an already connected manikin is listed
                                // straight away and the list is never empty while a device is connected.
                                child: StreamBuilder<OnConnectionStateChangedEvent>(
                                    stream: FlutterBluePlus.events.onConnectionStateChanged,
                                    builder: (context, _) => StreamBuilder<List<ScanResult>>(
                                        stream: controller.scanResults,
                                        initialData: const <ScanResult>[],
                                        builder: (context, snapshot) => _deviceList(devices: _mergeDevices(snapshot.data ?? const <ScanResult>[]))))),
                          ],
                        ),
                      ))));
        });
  }

  /// Connected manikins first (even if they are not in the current scan results), then the scanned CT devices.
  List<({BluetoothDevice device, int? rssi})> _mergeDevices(List<ScanResult> scanResults) {
    final connected = FlutterBluePlus.connectedDevices;
    final items = <({BluetoothDevice device, int? rssi})>[
      for (final device in connected) (device: device, rssi: scanResults.where((r) => r.device.remoteId == device.remoteId).map((r) => r.rssi).firstOrNull),
    ];
    for (final result in scanResults) {
      final alreadyListed = connected.any((d) => d.remoteId == result.device.remoteId);
      if (!alreadyListed && result.device.advName.toUpperCase().contains('CT')) {
        items.add((device: result.device, rssi: result.rssi));
      }
    }
    return items;
  }

  String _deviceName(BluetoothDevice device) {
    if (device.advName.isNotEmpty) return device.advName;
    if (device.platformName.isNotEmpty) return device.platformName;
    return 'Unknown device';
  }

  Widget _deviceList({required List<({BluetoothDevice device, int? rssi})> devices}) {
    return StreamBuilder<bool>(
      stream: FlutterBluePlus.isScanning,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.data == true && devices.isEmpty) {
          return BluetoothStateAndScanWidget(state: FlutterBluePlus.adapterStateNow, isScanningView: true);
        }
        final decoration = BoxDecoration(color: const Color.fromRGBO(233, 229, 255, 0.8), borderRadius: BorderRadius.circular(30));
        if (devices.isEmpty) {
          return Container(
            alignment: Alignment.center,
            decoration: decoration,
            padding: const EdgeInsets.all(20),
            child: Text("No manikin found.\nSwitch the manikin on and tap the refresh button.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
          );
        }
        return Container(
            decoration: decoration,
            child: RefreshIndicator(
              onRefresh: controller.startScanDevices,
              color: Colors.white,
              backgroundColor: AppColor.proPurple,
              child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: devices.length,
                  itemBuilder: (context, index) => _deviceRow(context, devices[index].device, devices[index].rssi)),
            ));
      },
    );
  }

  /// One device row. Sizes follow the screen type: compact on phones, roomier on tablets.
  Widget _deviceRow(BuildContext context, BluetoothDevice device, int? rssi) {
    final isTab = context.isTablet;
    final nameSize = isTab ? 15.0 : 13.0;
    final idSize = isTab ? 11.0 : 9.0;
    final buttonWidth = isTab ? 150.0 : 96.0;
    final buttonHeight = isTab ? 46.0 : 32.0;
    final initial = device.isConnected ? BluetoothConnectionState.connected : BluetoothConnectionState.disconnected;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: isTab ? 12 : 8, horizontal: 4),
          child: Row(
            spacing: isTab ? 16 : 10,
            children: [
              StreamBuilder<BluetoothConnectionState>(
                stream: device.connectionState,
                initialData: initial,
                builder: (context, connState) => _buildAvatar(connState.data == BluetoothConnectionState.connected, radius: isTab ? 24 : 18),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_deviceName(device), maxLines: 2, overflow: TextOverflow.ellipsis, style: MyTextTheme().mediumPUR.copyWith(fontFamily: 'Poppins-Regular', fontSize: nameSize)),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(device.remoteId.toString(), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColor.greyDark, fontSize: idSize, fontFamily: 'Poppins-Regular')),
                        if (rssi != null) _SignalStrengthBar(rssi: rssi),
                      ],
                    ),
                  ],
                ),
              ),
              StreamBuilder<BluetoothConnectionState>(
                stream: device.connectionState,
                initialData: initial,
                builder: (context, snapshot) {
                  final connected = snapshot.data == BluetoothConnectionState.connected;
                  return CustomGradientButton(
                    width: buttonWidth,
                    height: buttonHeight,
                    elevation: 1,
                    onTap: () async {
                      if (connected) {
                        // Already connected (e.g. returning to this list): go straight to the game.
                        ProgressDialogue().show(context, loadingText: 'Opening game');
                      } else {
                        ProgressDialogue().show(context, loadingText: 'Connecting');
                      }
                      controller.connectToDevice(device);
                    },
                    title: connected ? 'Play' : 'Connect',
                    textStyle: MyTextTheme().mediumWCB.copyWith(fontSize: isTab ? 13 : 11),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(height: 3, color: Colors.white, thickness: 1),
      ],
    );
  }

  Widget _buildAvatar(bool isConnected, {double radius = 18}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(backgroundColor: AppColor.proPurple, radius: radius, child: Icon(Icons.medical_services, color: Colors.white, size: radius)),
        if (isConnected)
          Positioned(bottom: -2, right: -2, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))),
      ],
    );
  }
}

class _SignalStrengthBar extends StatelessWidget {
  final int rssi;

  const _SignalStrengthBar({required this.rssi});

  int get _bars {
    if (rssi >= -60) return 4;
    if (rssi >= -70) return 3;
    if (rssi >= -80) return 2;
    return 1;
  }

  Color get _color {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final active = i < _bars;
        final barH = 4.0 + (i * 2.0);
        return Container(
          width: 4,
          height: barH,
          margin: const EdgeInsets.only(right: 2),
          alignment: Alignment.bottomCenter,
          child: Container(width: 4, height: active ? barH : 2, color: active ? _color : Colors.grey.withValues(alpha: 0.3)),
        );
      }),
    );
  }
}

class SpinningIcon extends StatefulWidget {
  final IconData iconData;
  final bool isSpinning;
  final Color? color;
  final double? size;

  const SpinningIcon({super.key, required this.iconData, required this.isSpinning, this.color, this.size});

  @override
  State<SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<SpinningIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (widget.isSpinning) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant SpinningIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning != oldWidget.isSpinning) {
      widget.isSpinning ? _controller.repeat() : _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _controller, child: Icon(widget.iconData, color: widget.color, size: widget.size));
}
