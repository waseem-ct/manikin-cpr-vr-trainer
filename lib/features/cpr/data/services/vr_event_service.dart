import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_env.dart';
import '../../domain/entities/cpr_event.dart';

/// Streams live CPR events to the VR server.
///
/// * Live events (compression / air blow) only matter in their latest state, so while one request is in flight a
///   newer live event simply replaces the waiting one. The VR side always sees the freshest state, never a backlog.
/// * The final result has its own slot: it is never replaced by live events, is sent first, and is retried until
///   the server accepts it (up to [_maxFinalAttempts] times).
/// * A failed request is retried with a growing delay (0.5 s ... 4 s).
class VrEventService {
  static const int _maxFinalAttempts = 20;

  Map<String, dynamic>? _latestLive;
  Map<String, dynamic>? _finalEvent;
  int _finalAttempts = 0;
  int _failures = 0;
  bool _isSending = false;

  /// Queues [event] for sending.
  void send(CprEvent event) {
    final json = event.toJson();
    if (event.isFinal) {
      _finalEvent = json;
      _finalAttempts = 0;
    } else {
      _latestLive = json;
    }
    if (!_isSending) _sendLoop();
  }

  /// Drops live events that have not been sent yet (a pending final result is kept).
  void clearLiveEvents() => _latestLive = null;

  Future<void> _sendLoop() async {
    _isSending = true;
    try {
      while (_finalEvent != null || _latestLive != null) {
        final isFinal = _finalEvent != null;
        final event = isFinal ? _finalEvent! : _latestLive!;
        if (await _post(event)) {
          _failures = 0;
          if (isFinal) {
            if (identical(event, _finalEvent)) _finalEvent = null;
          } else if (identical(event, _latestLive)) {
            _latestLive = null;
          }
        } else {
          _failures++;
          if (isFinal && ++_finalAttempts >= _maxFinalAttempts && identical(event, _finalEvent)) {
            debugPrint('VrEventService: giving up on the final result after $_finalAttempts attempts');
            _finalEvent = null;
          }
          await Future.delayed(Duration(milliseconds: (500 * _failures).clamp(500, 4000)));
        }
      }
    } finally {
      _isSending = false;
    }
  }

  Future<bool> _post(Map<String, dynamic> event) async {
    try {
      final response = await http.post(Uri.parse(AppEnv.vrEventUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode(event)).timeout(AppEnv.vrRequestTimeout);
      if (response.statusCode == 200) return true;
      debugPrint('VrEventService: server error ${response.statusCode}');
    } on TimeoutException {
      debugPrint('VrEventService: timeout');
    } catch (e) {
      debugPrint('VrEventService: $e');
    }
    return false;
  }
}
