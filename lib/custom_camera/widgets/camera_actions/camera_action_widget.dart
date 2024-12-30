import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/animated_capture_button.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/captured_media_preview.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/photo_capture_button.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_modes.dart';
import 'package:flutter/material.dart';

class CameraActionWidget extends StatelessWidget {
  const CameraActionWidget({
    super.key,
    required this.cameraState,
    required this.pageController,
  });

  final CameraState cameraState;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22.0),
                  child: SizedBox.square(
                    dimension: 46.0,
                    child: StreamBuilder<MediaCapture?>(
                      stream: cameraState.captureState$,
                      builder: (_, snapshot) {
                        if (snapshot.data == null) {
                          return const SizedBox.shrink();
                        }
                        return CapturedMediaPreview(
                          mediaCapture: snapshot.data!,
                          onMediaTap: (MediaCapture mediaCapture) {
                            //TODO: when clicked on preview image
                          },
                          state: cameraState,
                        );
                      },
                    ),
                  ),
                ),
                if (cameraState.captureMode == CaptureMode.video) ...[
                  AnimatedCaptureButton(cameraState: cameraState),
                ] else
                  PhotoCaptureButton(cameraState: cameraState),
                const SizedBox(
                  width: 48,
                )
                // IconButton(
                //   onPressed: () {
                //     widget.cameraState.switchCameraSensor();
                //   },
                //   icon: const Icon(
                //     Icons.autorenew,
                //     color: Colors.white,
                //     size: 32,
                //   ),
                // ),
              ],
            ),
            if (!(cameraState.captureState?.isRecordingVideo ?? false) ||
                cameraState.captureMode == CaptureMode.photo)
              CustomCameraModes(
                initialIndex:
                    cameraState.captureMode == CaptureMode.photo ? 0 : 1,
                availableModes: const [CaptureMode.photo, CaptureMode.video],
                onChangeCameraRequest: (captureMode) {
                  cameraState.setState(captureMode);
                },
                initialMode: CaptureMode.photo,
                on3DVideoTapped: () {
                  pageController.animateToPage(
                    1,
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 200),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
