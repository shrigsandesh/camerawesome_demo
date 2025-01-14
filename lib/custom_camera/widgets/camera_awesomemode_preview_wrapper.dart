import 'dart:developer';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_content.dart';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

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
            onMediaCaptureEvent: (media) async {
              if (media.captureRequest.path != null) {
                if (media.isPicture) {
                  await Gal.putImage(media.captureRequest.path!,
                      album: "Fishtechy");
                }
                if (media.isVideo) {
                  await Gal.putVideo(media.captureRequest.path!,
                      album: "Fishtechy");
                }
              }
            },
            saveConfig: SaveConfig.photoAndVideo(
                initialCaptureMode: cameraMode == FishtechyCameraMode.photo
                    ? CaptureMode.photo
                    : CaptureMode.video,
                photoPathBuilder: (sensors) async {
                  final Directory extDir = await getTemporaryDirectory();
                  final testDir = await Directory(
                    '${extDir.path}/camerawesome',
                  ).create(recursive: true);
                  if (sensors.length == 1) {
                    final String filePath =
                        '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                    log("filepath : $filePath");
                    return SingleCaptureRequest(filePath, sensors.first);
                  }
                  // Separate pictures taken with front and back camera
                  return MultipleCaptureRequest(
                    {
                      for (final sensor in sensors)
                        sensor:
                            '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
                    },
                  );
                }),
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
