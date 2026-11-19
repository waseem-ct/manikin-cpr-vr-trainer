import 'package:flutter/material.dart';

/// Four-bar signal indicator for an RSSI value in dBm.
class SignalStrengthBar extends StatelessWidget {
  const SignalStrengthBar({super.key, required this.rssi});

  final int rssi;

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
        final barHeight = 4.0 + (i * 2.0);
        return Container(
          width: 4,
          height: barHeight,
          margin: const EdgeInsets.only(right: 2),
          alignment: Alignment.bottomCenter,
          child: Container(width: 4, height: active ? barHeight : 2, color: active ? _color : Colors.grey.withValues(alpha: 0.3)),
        );
      }),
    );
  }
}
