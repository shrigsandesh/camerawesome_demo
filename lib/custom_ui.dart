import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/expandable_zoom_widget.dart';
import 'package:camerawesome_demo/grid_overlay.dart';
import 'package:camerawesome_demo/top_control_widget.dart';
import 'package:camerawesome_demo/utils/file_util.dart';
import 'package:camerawesome_demo/widgets/video_capture_button.dart';

import 'package:flutter/material.dart';

class CustomCameraUi extends StatelessWidget {
  const CustomCameraUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.custom(
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
                            ExpandableZoomControl(
                              state: cameraState,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    GridOverlay(),
                  ],
                ),
              ),
              _BottomControls(cameraState: cameraState),
            ],
          );
        },
        saveConfig: SaveConfig.photoAndVideo(),
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
            VideoCaptureButton(
              state: cameraState,
              captureDuration: const Duration(seconds: 5),
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
