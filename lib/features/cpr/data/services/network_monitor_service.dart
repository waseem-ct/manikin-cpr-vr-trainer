import 'dart:async';
import 'dart:io';

import '../../../../core/config/app_env.dart';

/// Periodically measures the connection time to the VR server (TCP connect to its host and port).
/// One instance per game session: call [start] when the game opens and [dispose] when it closes.
class NetworkMonitorService {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  Timer? _timer;

  /// Ping in ms; -1 = server unreachable.
  Stream<int> get pingStream => _controller.stream;

  void start() {
    _timer?.cancel();
    _measure();
    _timer = Timer.periodic(AppEnv.vrPingInterval, (_) => _measure());
  }

  Future<void> _measure() async {
    if (_controller.isClosed) return;
    try {
      final uri = Uri.parse(AppEnv.vrBaseUrl);
      final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);
      final watch = Stopwatch()..start();
      final socket = await Socket.connect(uri.host, port, timeout: const Duration(seconds: 2));
      watch.stop();
      socket.destroy();
      if (!_controller.isClosed) _controller.add(watch.elapsedMilliseconds);
    } catch (_) {
      if (!_controller.isClosed) _controller.add(-1);
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _controller.close();
  }
}
