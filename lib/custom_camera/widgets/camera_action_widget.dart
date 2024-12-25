import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/widgets/photo_capture_button.dart';
import 'package:camerawesome_demo/widgets/video_capture_button.dart';
import 'package:flutter/material.dart';

class CameraActionWidget extends StatelessWidget {
  const CameraActionWidget({super.key, required this.cameraState});

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
                        },
                        multiple: (multiple) {
                          multiple.fileBySensor.forEach((key, value) {
                            debugPrint(
                                'multiple file taken: $key ${value?.path}');
                          });
                        },
                      );
                    },
                  );
                },
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
          ],
        ),
      ),
    );
  }
}
