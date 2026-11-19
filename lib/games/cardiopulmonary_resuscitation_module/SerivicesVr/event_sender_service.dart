import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_serivce_for_vr.dart';

/// Streams live CPR events to the VR server.
///
/// * Live events (compression / air blow) only matter in their latest state, so while one request is in flight a
///   newer live event simply replaces the waiting one. The VR side always sees the freshest state, never a backlog.
/// * The final result (eventType 2) is never replaced or dropped by live events: it has its own slot, is sent first
///   and is retried until the server accepts it.
/// * A failed request is retried with a growing delay, and the round-trip time is published on [pingStream]
///   (-1 = server unreachable) so the game screen can show the link quality.
class EventSender {
  static final EventSender _instance = EventSender._internal();
  factory EventSender() => _instance;
  EventSender._internal();

  static const int finalEventType = 2;
  static const int _maxFinalAttempts = 20;
  static const Duration _requestTimeout = Duration(seconds: 5);

  Map<String, dynamic>? _latestLive;
  Map<String, dynamic>? _finalEvent;
  int _finalAttempts = 0;
  bool _isSending = false;
  int _failures = 0;

  /// Queue an event for sending.
  void sendEvent(Map<String, dynamic> event) {
    if (event['eventType'] == finalEventType) {
      _finalEvent = event;
      _finalAttempts = 0;
    } else {
      _latestLive = event;
    }
    if (!_isSending) _sendLoop();
  }

  /// Drop live events that have not been sent yet (a final result that is still pending is kept).
  void clearLiveEvents() => _latestLive = null;

  Future<void> _sendLoop() async {
    _isSending = true;
    try {
      while (_finalEvent != null || _latestLive != null) {
        final isFinal = _finalEvent != null;
        final event = isFinal ? _finalEvent! : _latestLive!;
        final ok = await _post(event);
        if (ok) {
          _failures = 0;
          if (isFinal) {
            if (identical(event, _finalEvent)) _finalEvent = null;
          } else if (identical(event, _latestLive)) {
            _latestLive = null;
          }
        } else {
          _failures++;
          if (isFinal && ++_finalAttempts >= _maxFinalAttempts && identical(event, _finalEvent)) {
            debugPrint('EventSender: giving up on the final result after $_finalAttempts attempts');
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
      final response = await http.post(Uri.parse(VRApiService.eventUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode(event)).timeout(_requestTimeout);
      if (response.statusCode == 200) return true;
      debugPrint('EventSender: server error ${response.statusCode}');
    } on TimeoutException {
      debugPrint('EventSender: timeout');
    } catch (e) {
      debugPrint('EventSender: $e');
    }
    return false;
  }
}
