import 'package:flutter/material.dart';

/// "VR server" link indicator: a green / orange / red dot with the ping. [compact] is a one-line, small variant.
class NetworkStatusBadge extends StatelessWidget {
  const NetworkStatusBadge({super.key, required this.pingStream, this.compact = false});

  final Stream<int> pingStream;
  final bool compact;

  Color _color(int ping) {
    if (ping < 0) return Colors.red;
    if (ping < 80) return Colors.green;
    if (ping < 200) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: pingStream,
      builder: (context, snapshot) {
        final ping = snapshot.data;
        final color = ping == null ? Colors.grey : _color(ping);
        final label = ping == null
            ? 'VR server...'
            : ping < 0
                ? 'VR server offline'
                : 'VR server $ping ms';
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: compact ? 8 : 12, color: color),
            SizedBox(width: compact ? 4 : 6),
            Text(label, style: TextStyle(fontSize: compact ? 11 : 13, fontWeight: FontWeight.w600, color: color)),
          ],
        );
      },
    );
  }
}
