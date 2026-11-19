/// Where the red/green pressure dots sit on a manikin image. All values are fractions of the image size.
class CprLayout {
  const CprLayout({
    required this.image,
    required this.gap,
    required this.leftDotTop,
    required this.leftDotRight,
    required this.leftDotLeft,
    required this.rightDotTop,
    required this.rightDotRight,
    required this.rightDotLeft,
    required this.centerDotTop,
    required this.centerDotRight,
    required this.centerDotLeft,
  });

  final String image;
  final double gap;
  final double leftDotTop, leftDotRight, leftDotLeft;
  final double rightDotTop, rightDotRight, rightDotLeft;
  final double centerDotTop, centerDotRight, centerDotLeft;
}
