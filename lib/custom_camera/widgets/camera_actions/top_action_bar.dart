import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class TopActionBar extends StatelessWidget {
  const TopActionBar({super.key, required this.state});

  final CameraState? state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: state != null
          ? Row(
              children: [
                FlashButton(
                  state: state!,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                InkWell(
                  onTap: () {
                    var currentRatio = state?.sensorConfig.aspectRatio;
                    switch (currentRatio) {
                      case CameraAspectRatios.ratio_16_9:
                        currentRatio = CameraAspectRatios.ratio_4_3;
                        break;
                      case CameraAspectRatios.ratio_4_3:
                        // Check if running on iOS before switching to 1:1
                        if (Theme.of(context).platform == TargetPlatform.iOS) {
                          currentRatio = CameraAspectRatios.ratio_1_1;
                        } else {
                          currentRatio = CameraAspectRatios.ratio_16_9;
                        }
                        break;
                      case CameraAspectRatios.ratio_1_1:
                        currentRatio = CameraAspectRatios.ratio_16_9;
                        break;
                      case null:
                        currentRatio = CameraAspectRatios.ratio_4_3;
                    }
                    state?.sensorConfig.setAspectRatio(currentRatio);
                  },
                  child: AspectRatioButton(
                    state: state!,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                )
              ],
            )
          : null,
    );
  }
}

class AspectRatioButton extends StatelessWidget {
  final CameraState state;

  const AspectRatioButton({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorConfig>(
      key: const ValueKey("ratioButton"),
      stream: state.sensorConfig$,
      builder: (_, sensorConfigSnapshot) {
        if (!sensorConfigSnapshot.hasData) {
          return const SizedBox.shrink();
        }
        final sensorConfig = sensorConfigSnapshot.requireData;
        return StreamBuilder<CameraAspectRatios>(
          stream: sensorConfig.aspectRatio$,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            return AwesomeOrientedWidget(
                child: switch (snapshot.data) {
              CameraAspectRatios.ratio_16_9 => Text(
                  '16:9',
                  style: context.bodyMedium,
                ),
              CameraAspectRatios.ratio_4_3 =>
                Text('4:3', style: context.bodyMedium),
              CameraAspectRatios.ratio_1_1 =>
                Text('1:1', style: context.bodyMedium),
              null => Text('4:3', style: context.bodyMedium),
            });
          },
        );
      },
    );
  }
}

class FlashButton extends StatelessWidget {
  final CameraState state;

  const FlashButton({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorConfig>(
      // Listen to the current SensorConfig. It might change when switching between front and back cameras.
      stream: state.sensorConfig$,
      builder: (_, sensorConfigSnapshot) {
        if (!sensorConfigSnapshot.hasData) {
          return const SizedBox.shrink();
        }
        final sensorConfig = sensorConfigSnapshot.requireData;
        return StreamBuilder<FlashMode>(
          // Listen to the currently selected flash mode
          stream: sensorConfig.flashMode$,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return InkWell(
              onTap: () {
                sensorConfig.switchCameraFlash();
              },
              child: FlashIcon(flashMode: snapshot.requireData),
            );
          },
        );
      },
    );
  }
}

class FlashIcon extends StatelessWidget {
  const FlashIcon({super.key, required this.flashMode});
  final FlashMode flashMode;

  @override
  Widget build(BuildContext context) {
    switch (flashMode) {
      case FlashMode.always:
        return const Icon(
          Icons.flashlight_on,
          color: Colors.white,
        );

      case FlashMode.auto:
        return const Icon(
          Icons.flash_auto,
          color: Colors.white,
        );

      case FlashMode.on:
        return const Icon(
          Icons.flash_on,
          color: Colors.white,
        );

      case FlashMode.none:
        return const Icon(
          Icons.flash_off,
          color: Colors.white,
        );
    }
  }
}
