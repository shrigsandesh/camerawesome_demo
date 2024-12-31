import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_content.dart';

import 'package:flutter/material.dart';

class CameraAwesomeModePreviewWrapper extends StatelessWidget {
  const CameraAwesomeModePreviewWrapper({
    super.key,
    required this.mode,
    required this.onStateChanged,
    required this.cameraMode,
  });
  final FishtechyCameraPreviewMode mode;
  final FishtechyCameraMode cameraMode;

  final ValueChanged<CameraState> onStateChanged;

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      FishtechyCameraPreviewMode.photoAndvideo => Scaffold(
          body: CameraAwesomeBuilder.custom(
            builder: (state, preview) {
              onStateChanged(state);
              return const CameraContent();
            },
            saveConfig: SaveConfig.photoAndVideo(
              initialCaptureMode: cameraMode == FishtechyCameraMode.photo
                  ? CaptureMode.photo
                  : CaptureMode.video,
            ),
          ),
        ),
      FishtechyCameraPreviewMode.threeD => const _3DCameraWidget(),
    };
  }
}

// ignore: camel_case_types
class _3DCameraWidget extends StatelessWidget {
  const _3DCameraWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('3d camera view'),
    );
  }
}
