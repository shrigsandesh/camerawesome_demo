import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/widgets/scrollable_bar_scale.dart';
import 'package:flutter/material.dart';

class ZoomSlider extends StatefulWidget {
  const ZoomSlider({super.key, required this.cameraState});

  final CameraState cameraState;

  @override
  State<ZoomSlider> createState() => _ZoomSliderState();
}

class _ZoomSliderState extends State<ZoomSlider> {
  double _currentValue = 1.0;
  bool _showBarSlider = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showBarSlider = !_showBarSlider;
            });
          },
          child: StreamBuilder<double>(
            stream: widget.cameraState.sensorConfig.zoom$,
            builder: (_, snapshot) {
              if (snapshot.data == null) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(.5)),
                child: Center(
                  child: Text(
                    "${_currentValue.toStringAsFixed(1)}x",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        ),
        if (_showBarSlider)
          ScrollableBarScale(
            onChanged: (value) {
              widget.cameraState.sensorConfig
                  .setZoom(normalizeZoom(value, 1, 2));
              setState(() {
                _currentValue = value;
              });
            },
          )
      ],
    );
  }
}

double normalizeZoom(double value, double minValue, double maxValue) {
  // Normalize the value using min-max normalization formula
  // (value - min) / (max - min)
  double normalizedValue = (value - minValue) / (maxValue - minValue);

  // Clamp the value between 0 and 1 to ensure it's in the desired range
  return normalizedValue.clamp(0.0, 1.0);
}
