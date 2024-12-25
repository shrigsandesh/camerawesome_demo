import 'dart:developer';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/grid_overlay.dart';
import 'package:camerawesome_demo/top_control_widget.dart';
import 'package:camerawesome_demo/utils/file_util.dart';
import 'package:camerawesome_demo/widgets/photo_capture_button.dart';
import 'package:camerawesome_demo/widgets/video_capture_button.dart';
import 'package:camerawesome_demo/widgets/zoom_slider.dart';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class CustomCameraUi extends StatelessWidget {
  const CustomCameraUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.custom(
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
        builder: (cameraState, preview) {
          return Column(
            children: [
              Container(
                color: Colors.black,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: TopControlWidget(
                  state: cameraState,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          children: [
                            const Spacer(),
                            ZoomSlider(
                              cameraState: cameraState,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const GridOverlay(),
                  ],
                ),
              ),
              ColoredBox(
                color: Colors.black,
                child: CameraModePager(
                    onChangeCameraRequest: (mode) {
                      cameraState.setState(mode);
                    },
                    availableModes: const [
                      CaptureMode.photo,
                      CaptureMode.video
                    ],
                    initialMode: CaptureMode.photo),
              ),
              _BottomControls(cameraState: cameraState),
            ],
          );
        },
        saveConfig: SaveConfig.photoAndVideo(photoPathBuilder: (sensors) async {
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
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({required this.cameraState});

  final CameraState cameraState;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                cameraState.switchCameraSensor();
              },
              icon: const Icon(
                Icons.cameraswitch_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            if (cameraState.captureMode == CaptureMode.video) ...[
              VideoCaptureButton(
                state: cameraState,
                captureDuration: const Duration(seconds: 5),
              ),
            ] else
              PhotoCaptureButton(
                state: cameraState,
              ),
            SizedBox(
              width: 45,
              child: StreamBuilder<MediaCapture?>(
                stream: cameraState.captureState$,
                builder: (_, snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  return AwesomeMediaPreview(
                    mediaCapture: snapshot.data!,
                    onMediaTap: (MediaCapture mediaCapture) {
                      mediaCapture.captureRequest.when(
                        single: (single) {
                          debugPrint('single: ${single.file?.path}');
                          single.file?.open();
                        },
                        multiple: (multiple) {
                          multiple.fileBySensor.forEach((key, value) {
                            debugPrint(
                                'multiple file taken: $key ${value?.path}');
                            value?.open();
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
