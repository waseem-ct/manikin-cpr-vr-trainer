class AppConstant {
  static const String appName = "CPR VR Trainer";

  static const String _assets = 'assets/';
  static const String imageFolderPath = '${_assets}game_images/';
  static const String otherImageFolderPath = '${_assets}other_images/';
  static const String jsonFilesPath = '${_assets}json_and_audio_files/';

  static const String exitMsg = 'Are You Sure\nYou Want To Exit?';
  static const String bleLostConnection = "It seems that you are not connected to Bluetooth. Check your Bluetooth Connection to continue playing.";

  /// Lottie animations
  static const String redDotAnimation = '${jsonFilesPath}red_dot_animation.json';
  static const String greenDotAnimation = '${jsonFilesPath}green_dot_animation.json';
  static const String apiLoaderAnimation = '${jsonFilesPath}api_loader_animation.json';
  static const String successAnimation = '${jsonFilesPath}success_arrow_animation.json';
  static const String unavailableData = '${jsonFilesPath}unavailable_data_animation.json';

  /// Images
  static const String backGroundImage = '${otherImageFolderPath}background_image.png';
  static const String appLogo = '${otherImageFolderPath}app_logo.png';

  /// Cardiopulmonary Resuscitation (CPR)
  static const int cprIncorrectA = 0;
  static const int cprIncorrectB = 0;
  static const String adultCPRString = "AdultCPR";
  static const String childCPRString = "ChildCPR";
  static const String neonatalCPRString = "NeonatalCPR";
  static const double cprAirBlowMaximumValue = 1.25;
  static const String airBlowAlertMsg = 'Now Give Rescue Breathe';
  static const String air_blow_image = '${imageFolderPath}air_blow_image.png';
  static const String adultCPRImage = '${imageFolderPath}cardiopulmonary_resuscitation_adult.png';
  static const String childCPRImage = '${imageFolderPath}cardiopulmonary_resuscitation_child.png';
  static const String neonatalCPRImage = '${imageFolderPath}cardiopulmonary_resuscitation_neonatal.png';
}
