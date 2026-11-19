import 'package:flutter/material.dart';

/// All colours used by the app. Nothing else should hard-code a hex value.
class AppColors {
  AppColors._();

  static const Color purple = Color.fromRGBO(103, 58, 183, 1);
  static const Color orange = Color.fromRGBO(255, 128, 0, 1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF23384D);
  static const Color grey = Color(0xFF616161);
  static const Color green = Colors.green;
  static final Color red = Colors.red.shade600;

  static const Color correct = Color.fromRGBO(20, 132, 12, 1);
  static const Color incorrect = Color.fromRGBO(255, 0, 0, 1);
  static const Color gaugeText = Color(0xFF4B73F1);
  static const Color gaugeTrack = Color(0xFFA2EEFF);

  /// Soft lilac used behind cards and lists.
  static const Color card = Color.fromRGBO(233, 229, 255, 0.8);
  static const Color cardSoft = Color.fromRGBO(233, 229, 255, 0.5);

  static const List<Color> primaryGradient = <Color>[Color(0xFF8F5BFE), Color(0xFF6368F8), Color(0xFF5698F6)];
  static const List<Color> successGradient = <Color>[Color(0xCC4CAF50), Color(0xFF388E3C)];
  static const List<Color> warningGradient = <Color>[Color(0xFFF66524), Color(0xFFF8A52B)];
  static const List<Color> gaugeGradient = <Color>[Color(0xFFA14AF9), Color(0xFF0ED6FF)];
}
