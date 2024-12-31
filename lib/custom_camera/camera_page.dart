import 'dart:developer';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/bottom_action_bar.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_awesomemode_preview_wrapper.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  late PageController previewPgController;
  late PageController modePgController;

  List<FishtechyCameraMode> availableModes = <FishtechyCameraMode>[];
  List<FishtechyCameraPreviewMode> availablePreviews =
      <FishtechyCameraPreviewMode>[];
  CameraState? state;
  FishtechyCameraMode selectedMode = FishtechyCameraMode.photo;

  int _currentIndex = 0;
  String? _time;

  void _onHorizontalDrag(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      // Swipe right logic remains same
      if (_currentIndex > 0) {
        _currentIndex--;
        if (selectedMode == FishtechyCameraMode.threeD) {
          setState(() {
            selectedMode = FishtechyCameraMode.video;
          });
          state?.setState(CaptureMode.video);
          previewPgController.animateToPage(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        } else if (selectedMode == FishtechyCameraMode.video) {
          setState(() {
            selectedMode = FishtechyCameraMode.photo;
          });
          state?.setState(CaptureMode.photo);
        }
      }
    } else if (details.delta.dx < 0) {
      // Swipe left

      var currentMode = selectedMode;
      if (_currentIndex < 2) {
        _currentIndex++;
        // log(selectedMode.toString());
        if (currentMode == FishtechyCameraMode.video) {
          log("left swipe when video here");

          currentMode = FishtechyCameraMode.threeD;

          previewPgController.animateToPage(1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        } else if (currentMode == FishtechyCameraMode.photo) {
          log("left swipe when photo here");

          currentMode = FishtechyCameraMode.video;

          state?.setState(CaptureMode.video);
        }
        setState(() {
          selectedMode = currentMode;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    availableModes = FishtechyCameraMode.values;
    availablePreviews = FishtechyCameraPreviewMode.values;
    previewPgController = PageController();
    modePgController = PageController(viewportFraction: 0.25, initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    previewPgController.dispose();
    modePgController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              flex: 2,
              child: ColoredBox(
                color: Colors.black,
                child: _time != null &&
                        (state?.captureState?.isRecordingVideo ?? false)
                    ? _VideoRecordingTimer(
                        isRecordingVideo:
                            (state?.captureState?.isRecordingVideo ?? false),
                        time: _time ?? "")
                    :
                    //  state != null
                    //     ? TopActionBar(state: state!)

                    // :
                    const SizedBox.expand(),
              )),
          Expanded(
            flex: 15,
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDrag,
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: previewPgController,
                onPageChanged: (index) {
                  if (index == 0) {
                    if (selectedMode == FishtechyCameraMode.video) {
                      previewPgController.animateToPage(
                        1,
                        duration: const Duration(microseconds: 400),
                        curve: Curves.linear,
                      );
                    }
                  }
                  if (index == 1) {
                    if (selectedMode == FishtechyCameraMode.photo) {
                      previewPgController.animateToPage(
                        0,
                        duration: const Duration(microseconds: 400),
                        curve: Curves.linear,
                      );
                      state?.setState(CaptureMode.video);
                    }
                  }
                },
                children: availablePreviews
                    .map(
                      (mode) => CameraAwesomeModePreviewWrapper(
                        cameraMode: selectedMode,
                        mode: mode,
                        onStateChanged: (camState) {
                          state = camState;
                          log(state.toString());
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: BottomActionBar(
              modePgController: modePgController,
              availableModes: availableModes,
              selectedMode: selectedMode,
              cameraState: state,
              onSelectionModeChanged: (index) {
                setState(() {
                  selectedMode = availableModes[index];
                });
                if (selectedMode == FishtechyCameraMode.video) {
                  previewPgController.animateToPage(
                    0,
                    duration: const Duration(microseconds: 400),
                    curve: Curves.linear,
                  );
                  state?.setState(CaptureMode.video);
                } else if (selectedMode == FishtechyCameraMode.photo) {
                  previewPgController.animateToPage(
                    0,
                    duration: const Duration(microseconds: 400),
                    curve: Curves.linear,
                  );
                  state?.setState(CaptureMode.photo);
                } else {
                  previewPgController.animateToPage(
                    1,
                    duration: const Duration(microseconds: 400),
                    curve: Curves.linear,
                  );
                }
              },
              onModeTapped: (tab) {
                setState(() {
                  selectedMode = availableModes[tab.index];
                });
                if (modePgController.hasClients) {
                  modePgController.animateToPage(tab.index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.linear);
                }
                if (selectedMode == FishtechyCameraMode.video) {
                  if (!previewPgController.hasClients) {
                    return;
                  }
                  previewPgController.animateToPage(
                    0,
                    duration: const Duration(microseconds: 400),
                    curve: Curves.linear,
                  );
                  state?.setState(CaptureMode.video);
                } else if (selectedMode == FishtechyCameraMode.photo) {
                  if (!previewPgController.hasClients) {
                    return;
                  }
                  previewPgController.animateToPage(
                    0,
                    duration: const Duration(microseconds: 400),
                    curve: Curves.linear,
                  );
                  state?.setState(CaptureMode.photo);
                } else {
                  if (!previewPgController.hasClients) {
                    return;
                  }
                  previewPgController.animateToPage(
                    1,
                    duration: const Duration(microseconds: 400),
                    curve: Curves.linear,
                  );
                }
              },
              onVideoRecording: (String? timer) {
                log(timer.toString());
                setState(() {
                  _time = timer;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoRecordingTimer extends StatelessWidget {
  const _VideoRecordingTimer(
      {required this.isRecordingVideo, required this.time});

  final bool isRecordingVideo;
  final String time;

  @override
  Widget build(BuildContext context) {
    return AwesomeOrientedWidget(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isRecordingVideo ? 1.0 : 0.2,
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 20.0),
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(12.0)),
            child: Align(
                widthFactor: 1,
                heightFactor: 1,
                alignment: Alignment.center,
                child: Text(
                  time,
                  style: context.bodyMedium,
                )),
          ),
        ),
      ),
    );
  }
}
