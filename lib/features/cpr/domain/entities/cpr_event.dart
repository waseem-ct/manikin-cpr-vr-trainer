/// What kind of event is sent to the VR server.
enum CprEventType {
  compression(0),
  airBlow(1),
  finalResult(2);

  const CprEventType(this.code);
  final int code;
}

/// One event for the VR server, serialised to the exact JSON the API expects.
class CprEvent {
  const CprEvent._({
    required this.type,
    this.pressure = 0,
    this.count = 0,
    this.timeLeft = 0,
    this.isCorrect = 0,
    this.correctCompression = 0,
    this.incorrectCompression = 0,
  });

  final CprEventType type;
  final int pressure;
  final int count;
  final int timeLeft;
  final int isCorrect;
  final int correctCompression;
  final int incorrectCompression;

  /// A compression was counted.
  factory CprEvent.compression({required int pressure, required int count, required int timeLeft, required bool isCorrect}) =>
      CprEvent._(type: CprEventType.compression, pressure: pressure, count: count, timeLeft: timeLeft, isCorrect: isCorrect ? 1 : 0);

  /// A rescue breath was counted ([count] is 1 or 2).
  factory CprEvent.airBlow({required int count, required int timeLeft}) => CprEvent._(type: CprEventType.airBlow, count: count, timeLeft: timeLeft);

  /// The session is over.
  factory CprEvent.finalResult({required int correct, required int incorrect}) => CprEvent._(type: CprEventType.finalResult, correctCompression: correct, incorrectCompression: incorrect);

  bool get isFinal => type == CprEventType.finalResult;

  Map<String, dynamic> toJson() => {
        'eventType': type.code,
        'pressure': pressure,
        'count': count,
        'timeLeft': timeLeft,
        'isCorrect': isCorrect,
        'correctCompression': correctCompression,
        'inCorrectCompression': incorrectCompression,
      };
}
