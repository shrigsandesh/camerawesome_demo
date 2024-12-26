import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/captured_media_preview.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/video_capture_button.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_modes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        child: Column(
          children: [
            CustomCameraModes(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 46.0,
                  height: 46.0,
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
                if (cameraState.captureMode == CaptureMode.video) ...[
                  VideoCaptureButton(cameraState: cameraState),
                  // InkWell(
                  //   onTap: () {
                  //     //TODO: after capturing video
                  //     cameraState.when(
                  //         onVideoMode: (videoCameraState) =>
                  //             videoCameraState.startRecording(),
                  //         onVideoRecordingMode: (videoRecordingCameraState) =>
                  //             videoRecordingCameraState.stopRecording());
                  //   },
                  //   child: (cameraState.captureState?.isRecordingVideo ?? false)
                  //       ? const SizedBox(
                  //           height: 60.0,
                  //           child: CircleAvatar(
                  //               backgroundColor: Colors.white,
                  //               child: Icon(
                  //                 Icons.stop,
                  //                 color: Colors.red,
                  //               )),
                  //         )
                  //       : SvgPicture.asset(
                  //           'assets/video_lens.svg',
                  //           height: 60.0,
                  //           width: 60.0,
                  //         ),
                  // ),
                ] else
                  InkWell(
                    onTap: () {
                      //TODO: after capturing picture
                      cameraState.when(
                        onPhotoMode: (cameraState) => cameraState.takePhoto(),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/photo_lens.svg',
                      height: 60.0,
                      width: 60.0,
                    ),
                  ),
                // const SizedBox(
                //   width: 48,
                // )
                IconButton(
                  onPressed: () {
                    cameraState.switchCameraSensor();
                  },
                  icon: const Icon(
                    Icons.autorenew,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
