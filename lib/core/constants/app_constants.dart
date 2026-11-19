/// Shared, non-secret constants. Deployment-specific values (URLs, UUIDs) live in `.env` -> [AppEnv].
class AppConstants {
  AppConstants._();

  static const String appName = 'CPR VR Trainer';
  static const String exitMessage = 'Are You Sure\nYou Want To Exit?';
  static const String bleLostConnectionMessage = 'It seems that you are not connected to Bluetooth. Check your Bluetooth Connection to continue playing.';
  static const String airBlowPromptMessage = 'Now Give Rescue Breathe';
  static const String airBlowRequiredMessage = 'This step cannot be skipped.\n Complete the required rescue breaths to continue.';

  /// Delay before the splash screen hands over to the dashboard.
  static const Duration splashDuration = Duration(milliseconds: 3000);
}

/// Asset paths.
class AppAssets {
  AppAssets._();

  static const String _images = 'assets/game_images/';
  static const String _other = 'assets/other_images/';
  static const String _anim = 'assets/json_and_audio_files/';

  static const String appLogo = '${_other}app_logo.png';
  static const String background = '${_other}background_image.png';

  static const String manikinAdult = '${_images}cardiopulmonary_resuscitation_adult.png';
  static const String manikinChild = '${_images}cardiopulmonary_resuscitation_child.png';
  static const String manikinNeonatal = '${_images}cardiopulmonary_resuscitation_neonatal.png';
  static const String airBlow = '${_images}air_blow_image.png';

  static const String redDot = '${_anim}red_dot_animation.json';
  static const String greenDot = '${_anim}green_dot_animation.json';
  static const String loader = '${_anim}api_loader_animation.json';
  static const String success = '${_anim}success_arrow_animation.json';
  static const String unavailable = '${_anim}unavailable_data_animation.json';
}
