import 'package:flutter/widgets.dart';

/// Screen-size helpers.
extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// True on tablets (shortest side >= 600 logical pixels).
  bool get isTablet => screenSize.shortestSide >= 600;
}
