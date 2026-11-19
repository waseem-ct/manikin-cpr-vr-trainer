import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text styles. Sizes are logical pixels; scale with `copyWith(fontSize: ...)` where a screen needs it.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _poppins(Color color, double size, FontWeight weight) => GoogleFonts.poppins(color: color, fontSize: size, fontWeight: weight);

  // White
  static TextStyle get whiteSmallBold => _poppins(AppColors.white, 12, FontWeight.bold);
  static TextStyle get whiteMediumBold => _poppins(AppColors.white, 14, FontWeight.bold);
  static TextStyle get whiteLargeBold => _poppins(AppColors.white, 18, FontWeight.bold);
  static TextStyle get whiteHugeBold => _poppins(AppColors.white, 45, FontWeight.normal);
  static TextStyle get whiteMedium => _poppins(AppColors.white, 14, FontWeight.normal);
  static TextStyle get whiteLarge => _poppins(AppColors.white, 18, FontWeight.normal);

  // Purple
  static TextStyle get purpleMedium => _poppins(AppColors.purple, 16, FontWeight.normal);
  static TextStyle get purpleLarge => _poppins(AppColors.purple, 18, FontWeight.w500);

  // Dark text
  static TextStyle get darkMediumBold => _poppins(AppColors.text, 14, FontWeight.bold);
  static TextStyle get darkHugeBold => _poppins(AppColors.text, 22, FontWeight.bold);

  /// Countdown digits.
  static TextStyle get timer => GoogleFonts.bebasNeue(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold);
}
