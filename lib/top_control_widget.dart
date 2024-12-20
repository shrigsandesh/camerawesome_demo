import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class TopControlWidget extends StatefulWidget {
  const TopControlWidget({super.key, required this.state});

  final CameraState state;

  @override
  State<TopControlWidget> createState() => _TopControlWidgetState();
}

class _TopControlWidgetState extends State<TopControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder<FlashMode>(
          stream: widget.state.sensorConfig.flashMode$,
          builder: (_, snapshot) {
            if (snapshot.data == null) {
              return const SizedBox.shrink();
            }
            return Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black.withOpacity(.2)),
              child: IconButton(
                onPressed: () {
                  if (snapshot.data == FlashMode.on) {
                    widget.state.sensorConfig.setFlashMode(FlashMode.none);
                    return;
                  }
                  widget.state.sensorConfig.setFlashMode(FlashMode.on);
                },
                icon: snapshot.data == FlashMode.on
                    ? const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.flash_off,
                        color: Colors.white,
                      ),
              ),
            );
          },
        ),
        StreamBuilder<CameraAspectRatios>(
          stream: widget.state.sensorConfig.aspectRatio$,
          builder: (_, snapshot) {
            if (snapshot.data == null) {
              return const SizedBox.shrink();
            }
            return Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black.withOpacity(.2)),
              child: GestureDetector(
                  onTap: () {
                    widget.state.sensorConfig.switchCameraRatio();
                  },
                  child: Center(child: AspectRatioWidget(state: widget.state))),
            );
          },
        ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }
}

class AspectRatioWidget extends StatelessWidget {
  const AspectRatioWidget({super.key, required this.state});
  final CameraState state;

  @override
  Widget build(BuildContext context) {
    switch (state.sensorConfig.aspectRatio) {
      case CameraAspectRatios.ratio_16_9:
        return const Text(
          "16:9",
          style: TextStyle(color: Colors.white),
        );
      case CameraAspectRatios.ratio_4_3:
        return const Text(
          "4:3",
          style: TextStyle(color: Colors.white),
        );
      case CameraAspectRatios.ratio_1_1:
        return const Text(
          "1:1",
          style: TextStyle(color: Colors.white),
        );
    }
  }
}
