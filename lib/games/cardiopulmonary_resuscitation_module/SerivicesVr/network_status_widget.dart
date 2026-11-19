import 'package:flutter/material.dart';

/// Small "VR server" link indicator: green / orange / red dot with the ping.
class NetworkStatusWidget extends StatelessWidget {
  final Stream<int> pingStream;

  const NetworkStatusWidget({super.key, required this.pingStream});

  Color _pingColor(int ping) {
    if (ping < 0) return Colors.red;
    if (ping < 80) return Colors.green;
    if (ping < 200) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: pingStream,
      builder: (context, snap) {
        final ping = snap.data;
        final color = ping == null ? Colors.grey : _pingColor(ping);
        final label = ping == null
            ? 'VR server: checking...'
            : ping < 0
                ? 'VR server: not reachable'
                : 'VR server: $ping ms';
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 12, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        );
      },
    );
  }
}
