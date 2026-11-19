import 'dart:async';
import 'dart:io';

import 'api_serivce_for_vr.dart';

/// Periodically measures the connection time to the VR server (TCP connect to its host/port).
class NetworkMonitor {
  StreamController<int>? _pingController = StreamController<int>.broadcast();

  /// Ping in ms; -1 = server unreachable.
  Stream<int> get pingStream => _pingController?.stream ?? const Stream<int>.empty();

  Timer? _timer;

  void startMonitoring({Duration interval = const Duration(seconds: 3)}) {
    _timer?.cancel();
    _measurePing();
    _timer = Timer.periodic(interval, (_) => _measurePing());
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _pingController?.close();
    _pingController = null;
  }

  Future<void> _measurePing() async {
    final controller = _pingController;
    if (controller == null || controller.isClosed) return;
    try {
      final uri = Uri.parse(VRApiService.baseUrl);
      final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      final sw = Stopwatch()..start();
      final socket = await Socket.connect(uri.host, port, timeout: const Duration(seconds: 2));
      sw.stop();
      socket.destroy();
      if (!controller.isClosed) controller.add(sw.elapsedMilliseconds);
    } catch (_) {
      if (!controller.isClosed) controller.add(-1);
    }
  }
}
