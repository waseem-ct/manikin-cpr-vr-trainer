class CPRConfig {
  final String image;
  final double gap;
  final double leftRedDotTop;
  final double leftRedDotRight;
  final double leftRedDotLeft;
  final double rightRedDotTop;
  final double rightRedDotLeft;
  final double rightRedDotRight;
  final double centerGreenRedDotTop;
  final double centerGreenRedDotRight;
  final double centerGreenRedDotLeft;

  CPRConfig({
    required this.image,
    required this.gap,
    required this.leftRedDotTop,
    required this.leftRedDotRight,
    required this.leftRedDotLeft,
    required this.rightRedDotTop,
    required this.rightRedDotLeft,
    required this.rightRedDotRight,
    required this.centerGreenRedDotTop,
    required this.centerGreenRedDotRight,
    required this.centerGreenRedDotLeft,
  });

  // Factory constructor to create CPRConfig from JSON-like map
  factory CPRConfig.fromJson(Map<String, dynamic> json) {
    return CPRConfig(
      image: json['image'],
      gap: json['gap'] ?? 0.0,
      leftRedDotTop: json['leftRedDotTop'] ?? 0.0,
      leftRedDotRight: json['leftRedDotRight'] ?? 0.0,
      leftRedDotLeft: json['leftRedDotLeft'] ?? 0.0,
      rightRedDotTop: json['rightRedDotTop'] ?? 0.0,
      rightRedDotLeft: json['rightRedDotLeft'] ?? 0.0,
      rightRedDotRight: json['rightRedDotRight'] ?? 0.0,
      centerGreenRedDotTop: json['centerGreenRedDotTop'] ?? 0.0,
      centerGreenRedDotRight: json['centerGreenRedDotRight'] ?? 0.0,
      centerGreenRedDotLeft: json['centerGreenRedDotLeft'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'gap': gap,
      'leftRedDotTop': leftRedDotTop,
      'leftRedDotRight': leftRedDotRight,
      'leftRedDotLeft': leftRedDotLeft,
      'rightRedDotTop': rightRedDotTop,
      'rightRedDotLeft': rightRedDotLeft,
      'rightRedDotRight': rightRedDotRight,
      'centerGreenRedDotTop': centerGreenRedDotTop,
      'centerGreenRedDotRight': centerGreenRedDotRight,
      'centerGreenRedDotLeft': centerGreenRedDotLeft
    };
  }
}
