import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';

/// Floating refresh button that spins while a scan is running.
class ScanButton extends StatelessWidget {
  const ScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isScanning = context.select<BluetoothProvider, bool>((p) => p.isScanning);
    return FloatingActionButton(
      shape: const CircleBorder(),
      backgroundColor: Colors.orange,
      tooltip: 'Scan',
      onPressed: isScanning ? null : context.read<BluetoothProvider>().scan,
      child: _SpinningIcon(isSpinning: isScanning),
    );
  }
}

class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon({required this.isSpinning});

  final bool isSpinning;

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    if (widget.isSpinning) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _SpinningIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning != oldWidget.isSpinning) widget.isSpinning ? _controller.repeat() : _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _controller, child: const Icon(Icons.refresh, color: Colors.white, size: 30));
}
