import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// One row of the device list.
class BleDeviceItem {
  const BleDeviceItem({required this.device, required this.name, required this.isManikin, this.rssi});

  final BluetoothDevice device;
  final String name;

  /// True when the name matches the configured manikin keyword (shown first, with a highlighted icon).
  final bool isManikin;

  /// Signal strength in dBm, or null when the device is connected but not in the current scan.
  final int? rssi;
}
