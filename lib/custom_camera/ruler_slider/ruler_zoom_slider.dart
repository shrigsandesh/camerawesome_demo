import 'package:camerawesome_demo/custom_camera/ruler_slider/ruler_slider.dart';
import 'package:flutter/material.dart';

class RulerZoomSlider extends StatelessWidget {
  const RulerZoomSlider({super.key, required this.onChanged});

  final Function(double value) onChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withOpacity(.5),
      child: RulerSlider(
        minValue: 1.0,
        maxValue: 20.0,
        initialValue: 1.0,
        rulerHeight: 80.0,
        selectedBarColor: Colors.yellow,
        unselectedBarColor: Colors.grey,
        tickSpacing: 10.0,
        valueTextStyle: const TextStyle(color: Colors.yellow, fontSize: 18),
        onChanged: onChanged,
        showFixedBar: true,
        fixedBarColor: Colors.yellow,
        fixedBarWidth: 3.0,
        fixedBarHeight: 40.0,
        showFixedLabel: true,
        fixedLabelColor: Colors.white,
        scrollSensitivity: 1.0,
        enableSnapping: true,
        majorTickInterval: 5,
        labelInterval: 10,
        labelVerticalOffset: 30.0,
        showBottomLabels: false,
        labelTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
        majorTickHeight: 15.0,
        minorTickHeight: 10.0,
      ),
    );
  }
}
