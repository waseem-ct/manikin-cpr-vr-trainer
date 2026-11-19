import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../providers/cpr_provider.dart';
import 'network_status_badge.dart';

/// Slim game top bar: back button, the Bluetooth status with the VR ping underneath, and a settings menu.
class CprAppBar extends StatelessWidget {
  const CprAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CprProvider>();
    return AppHeader(
      compact: true,
      onBack: provider.confirmExit,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Selector<CprProvider, bool>(
            selector: (_, p) => p.isDeviceConnected,
            builder: (_, connected, __) => ConnectionStatusLabel(isConnected: connected),
          ),
          NetworkStatusBadge(pingStream: provider.pingStream, compact: true),
        ],
      ),
      trailing: Selector<CprProvider, bool>(
        selector: (_, p) => p.withAirBlow,
        builder: (_, withAirBlow, __) => AirBlowMenu(value: withAirBlow, onChanged: provider.setWithAirBlow),
      ),
    );
  }
}

/// Green "Connected" / red "Disconnected" label with a Bluetooth icon in the same colour.
class ConnectionStatusLabel extends StatelessWidget {
  const ConnectionStatusLabel({super.key, required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? Colors.green.shade700 : Colors.red.shade900;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(isConnected ? Icons.bluetooth_connected_sharp : Icons.bluetooth_disabled_sharp, color: color, size: 16),
        const SizedBox(width: 4),
        Text(isConnected ? 'Connected' : 'Disconnected', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Settings button that opens a small menu with the "With Air Blow" checkbox.
class AirBlowMenu extends StatelessWidget {
  const AirBlowMenu({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Settings',
      elevation: 8,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      itemBuilder: (_) => [
        PopupMenuItem<void>(child: _AirBlowCheckbox(initial: value, onChanged: onChanged)),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.purple),
        child: const Icon(Icons.settings, color: Colors.white, size: 22),
      ),
    );
  }
}

/// Checkbox row inside the popup menu. The menu lives outside the provider tree, so it keeps its own copy of the
/// value while open and reports each change through [onChanged].
class _AirBlowCheckbox extends StatefulWidget {
  const _AirBlowCheckbox({required this.initial, required this.onChanged});

  final bool initial;
  final ValueChanged<bool> onChanged;

  @override
  State<_AirBlowCheckbox> createState() => _AirBlowCheckboxState();
}

class _AirBlowCheckboxState extends State<_AirBlowCheckbox> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.purple,
      checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: const Text('With Air Blow', style: TextStyle(fontWeight: FontWeight.bold)),
      value: _value,
      onChanged: (v) {
        setState(() => _value = v ?? _value);
        widget.onChanged(_value);
      },
    );
  }
}
