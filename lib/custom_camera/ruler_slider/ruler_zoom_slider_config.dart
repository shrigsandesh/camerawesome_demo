import 'package:flutter/material.dart';

class RulerZoomSliderConfig {
  final double? minValue;
  final double maxZoomBars;
  final double rulerHeight;
  final Color selectedBarColor;
  final Color unselectedBarColor;
  final double tickSpacing;
  final TextStyle valueTextStyle;
  final Color fixedBarColor;
  final double fixedBarWidth;
  final double fixedBarHeight;
  final Color fixedLabelColor;
  final double scrollSensitivity;
  final int majorTickInterval;
  final int labelInterval;
  final TextStyle labelTextStyle;
  final double majorTickHeight;
  final double minorTickHeight;
  final List<double> zoomLevels;
  final Widget Function(double)? displayValueBuilder;
  final double? maxDisplayValue;

  const RulerZoomSliderConfig({
    this.minValue,
    this.maxZoomBars = RulerZoomConstants.defaultMaxZoomBars,
    this.rulerHeight = RulerZoomConstants.defaultRulerHeight,
    this.selectedBarColor = Colors.yellow,
    this.unselectedBarColor = Colors.grey,
    this.tickSpacing = RulerZoomConstants.defaultTickSpacing,
    this.valueTextStyle = const TextStyle(color: Colors.yellow, fontSize: 18),
    this.fixedBarColor = Colors.yellow,
    this.fixedBarWidth = RulerZoomConstants.defaultFixedBarWidth,
    this.fixedBarHeight = RulerZoomConstants.defaultFixedBarHeight,
    this.fixedLabelColor = Colors.white,
    this.scrollSensitivity = 1.0,
    this.majorTickInterval = 4,
    this.labelInterval = 10,
    this.labelTextStyle = const TextStyle(color: Colors.black, fontSize: 12),
    this.majorTickHeight = 15.0,
    this.minorTickHeight = 10.0,
    this.zoomLevels = RulerZoomConstants.defaultZoomLevels,
    this.displayValueBuilder,
    this.maxDisplayValue,
  });
}

class RulerZoomConstants {
  static const defaultMinZoom = 1.0;
  static const defaultMaxZoomBars = 10.0;
  static const defaultRulerHeight = 80.0;
  static const defaultTickSpacing = 10.0;
  static const defaultFixedBarWidth = 3.0;
  static const defaultFixedBarHeight = 40.0;
  static const defaultZoomLevels = [1.0, 2.0, 4.0, 10.0];
  static const defaultButtonSize = 28.0;
  static const defaultButtonMargin = 4.0;

  static const animationDuration = Duration(seconds: 1);
}
