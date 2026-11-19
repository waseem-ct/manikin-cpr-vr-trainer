/// One reading from the manikin. The manikin sends it as a comma separated ASCII string:
/// `pressure,rightCompression,leftCompression,airBlow`.
class CprSensorData {
  const CprSensorData({this.pressure = 0, this.rightCompression = 1, this.leftCompression = 1, this.airBlow = 1.13});

  /// Compression depth/pressure, 0-10. 0 means nothing is pressing the chest.
  final int pressure;

  /// 0 when the right / left side is pressed incorrectly (red dot), otherwise 1.
  final int rightCompression;
  final int leftCompression;

  /// Air-blow sensor value; above [airBlowThreshold] counts as a rescue breath.
  final double airBlow;

  static const double airBlowThreshold = 1.25;
  static const int incorrectSide = 0;

  /// Number of fields a valid packet has.
  static const int fieldCount = 4;

  bool get isLeftIncorrect => leftCompression == incorrectSide;
  bool get isRightIncorrect => rightCompression == incorrectSide;
  bool get isBreath => airBlow > airBlowThreshold;

  /// Parses a packet; returns null when it has too few fields.
  static CprSensorData? fromPacket(List<dynamic> packet) {
    if (packet.length < fieldCount) return null;
    return CprSensorData(
      pressure: int.tryParse(packet[0].toString().trim()) ?? 0,
      rightCompression: int.tryParse(packet[1].toString().trim()) ?? 1,
      leftCompression: int.tryParse(packet[2].toString().trim()) ?? 1,
      airBlow: double.tryParse(packet[3].toString().trim()) ?? 1.13,
    );
  }

  /// Same reading with only the air-blow value taken from [other] (used while a dialog hides the chest dots).
  CprSensorData withAirBlowFrom(CprSensorData other) => CprSensorData(pressure: pressure, rightCompression: rightCompression, leftCompression: leftCompression, airBlow: other.airBlow);
}
