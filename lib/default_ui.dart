import 'dart:developer';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:camerawesome_demo/utils/file_util.dart';
import 'package:path_provider/path_provider.dart';

class DefaultCameraAswesomeUI extends StatelessWidget {
  const DefaultCameraAswesomeUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(
          initialCaptureMode: CaptureMode.photo,
          photoPathBuilder: (sensors) async {
            final Directory extDir = await getTemporaryDirectory();
            final testDir = await Directory(
              '${extDir.path}/camerawesome',
            ).create(recursive: true);
            if (sensors.length == 1) {
              final String filePath =
                  '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

              var capture = SingleCaptureRequest(filePath, sensors.first);
              log("file path: ${capture.file?.path}");
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
          },
          videoOptions: VideoOptions(
            enableAudio: true,
            ios: CupertinoVideoOptions(
              fps: 10,
            ),
            android: AndroidVideoOptions(
              bitrate: 6000000,
              fallbackStrategy: QualityFallbackStrategy.lower,
            ),
          ),
          exifPreferences: ExifPreferences(saveGPSLocation: true),
        ),
        defaultFilter: AwesomeFilter.vintage,
        onMediaTap: (mediaCapture) {
          mediaCapture.captureRequest.when(
            single: (single) {
              debugPrint('single: ${single.file?.path}');
              single.file?.open();
            },
            multiple: (multiple) {
              multiple.fileBySensor.forEach((key, value) {
                debugPrint('multiple file taken: $key ${value?.path}');
                value?.open();
              });
            },
          );
        },
      ),
    );
  }
}
