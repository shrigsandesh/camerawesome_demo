import 'package:flutter/material.dart';

class CameraConstants {
  static const double outerHorizontalSpacing = 30.0;
  static const double outerVerticalSpacing = 40.0;
  static const double innerHorizontalSpacing = 50.0;
  static const double innerVerticalSpacing = 89.0;
  static const double borderRadius = 36.0;

  static const EdgeInsets outerPadding = EdgeInsets.symmetric(
    horizontal: outerHorizontalSpacing,
    vertical: outerVerticalSpacing,
  );

  static EdgeInsets getInnerPadding() {
    return const EdgeInsets.symmetric(
      horizontal: outerHorizontalSpacing + innerHorizontalSpacing,
      vertical: outerVerticalSpacing + innerVerticalSpacing,
    );
  }
}
