import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class TopActionBar extends StatelessWidget {
  const TopActionBar({super.key, required this.state});

  final CameraState? state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (state != null)
            FlashButton(
              state: state!,
            ),
        ],
      ),
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
