import 'package:flutter/material.dart';

/// Animated ripple with a pulsing Bluetooth icon, shown while scanning with no results yet.
class BluetoothScanningView extends StatefulWidget {
  const BluetoothScanningView({super.key, this.iconSize = 65, this.rings = true});

  final double iconSize;
  final bool rings;

  @override
  State<BluetoothScanningView> createState() => _BluetoothScanningViewState();
}

class _BluetoothScanningViewState extends State<BluetoothScanningView> with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(vsync: this, lowerBound: 0.5, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ripple,
      builder: (context, _) {
        final t = Curves.fastOutSlowIn.transform(_ripple.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            if (widget.rings)
              for (final radius in const [100.0, 170.0, 230.0, 290.0, 350.0])
                Container(
                  width: radius * t,
                  height: radius * t,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor.withValues(alpha: 1 - _ripple.value)),
                ),
            Opacity(opacity: _ripple.value.clamp(0.3, 1.0), child: Icon(Icons.bluetooth, size: widget.iconSize, color: Colors.white)),
          ],
        );
      },
    );
  }
}
