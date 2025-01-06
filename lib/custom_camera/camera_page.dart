import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/bottom_action_bar.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/top_action_bar.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_awesomemode_preview_wrapper.dart';
import 'package:camerawesome_demo/custom_camera/widgets/zoom_bar.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  late final PageController _previewController;
  late final PageController _modeController;

  List<FishtechyCameraMode> availableModes = <FishtechyCameraMode>[];
  List<FishtechyCameraPreviewMode> availablePreviews =
      <FishtechyCameraPreviewMode>[];
  CameraState? _cameraState;
  FishtechyCameraMode _selectedMode = FishtechyCameraMode.photo;

  String? _recordingTime;
  int _currentIndex = 0;

  static const _kAnimationDuration = Duration(milliseconds: 300);
  static const _kSwipeThreshold = 500.0;

  double? zoomlevel;

  @override
  void initState() {
    super.initState();
    availableModes = FishtechyCameraMode.values;
    availablePreviews = FishtechyCameraPreviewMode.values;
    _previewController = PageController();
    _modeController = PageController(viewportFraction: 0.25, initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
    _previewController.dispose();
    _modeController.dispose();
  }

  void _animateToPreview({
    required int previewIndex,
    required int modeIndex,
    bool previewOnly = false,
    bool modesOnly = false,
  }) {
    if (!modesOnly) {
      _previewController.animateToPage(
        previewIndex,
        duration: _kAnimationDuration,
        curve: Curves.easeInOut,
      );
    }
    if (!previewOnly) {
      _modeController.animateToPage(
        modeIndex,
        duration: _kAnimationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  void _onHorizontalDrag(DragEndDetails? details) {
    if (details == null) return;

    if (details.primaryVelocity! > _kSwipeThreshold) {
      // Swipe right
      if (_currentIndex > 0) {
        _currentIndex--;
        switch (_selectedMode) {
          case FishtechyCameraMode.threeD:
            setState(() {
              _selectedMode = FishtechyCameraMode.video;
            });
            _cameraState?.setState(CaptureMode.video);
            _animateToPreview(previewIndex: 0, modeIndex: 1);
            break;

          case FishtechyCameraMode.video:
            setState(() {
              _selectedMode = FishtechyCameraMode.photo;
            });
            _cameraState?.setState(CaptureMode.photo);
            _animateToPreview(previewIndex: 0, modeIndex: 0);
            break;
          default:
        }
      }
    } else {
      // Swipe left

      var currentMode = _selectedMode;

      if (_currentIndex < 2) {
        _currentIndex++;

        switch (_selectedMode) {
          case FishtechyCameraMode.video:
            currentMode = FishtechyCameraMode.threeD;
            _animateToPreview(previewIndex: 1, modeIndex: 1);
            break;

          case FishtechyCameraMode.photo:
            currentMode = FishtechyCameraMode.video;
            _cameraState?.setState(CaptureMode.video);
            _modeController.animateToPage(1,
                duration: _kAnimationDuration, curve: Curves.easeInOut);
            break;
          default:
        }

        setState(() {
          _selectedMode = currentMode;
        });
      }
    }
  }

  void _animateToPage(int pageIndex) {
    if (_previewController.hasClients) {
      _previewController.animateToPage(
        pageIndex,
        duration: const Duration(microseconds: 400),
        curve: Curves.linear,
      );
    }
  }

  void _updateCameraState(FishtechyCameraMode mode) {
    if (mode == FishtechyCameraMode.video) {
      _cameraState?.setState(CaptureMode.video);
      _animateToPage(0);
    } else if (mode == FishtechyCameraMode.photo) {
      _cameraState?.setState(CaptureMode.photo);
      _animateToPage(0);
    } else {
      _animateToPage(1);
    }
  }

  void _onSelectionModeChanged(int index) {
    setState(() {
      _selectedMode = availableModes[index];
    });
    _updateCameraState(_selectedMode);
  }

  void _onModeTapped(FishtechyCameraMode tab) {
    setState(() {
      _selectedMode = availableModes[tab.index];
    });

    if (_modeController.hasClients) {
      _modeController.animateToPage(
        tab.index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    }

    _updateCameraState(_selectedMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              flex: 2,
              child: _buildTopActionBar(
                _recordingTime,
                _cameraState,
              )),
          Expanded(
            flex: 15,
            child: GestureDetector(
              onHorizontalDragEnd: _onHorizontalDrag,
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _previewController,
                children: availablePreviews
                    .map(
                      (mode) => CameraAwesomeModePreviewWrapper(
                        cameraMode: _selectedMode,
                        mode: mode,
                        onStateChanged: (camState) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _cameraState = camState;
                            });
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          if (_cameraState != null)
            ColoredBox(
                color: Colors.black.withOpacity(.8),
                child: ZoomBar(
                  onZoomChanged: (val) {
                    setState(() {
                      zoomlevel = val;
                    });
                  },
                  cameraState: _cameraState,
                )),
          Expanded(
            flex: 3,
            child: BottomActionBar(
              modePgController: _modeController,
              availableModes: availableModes,
              selectedMode: _selectedMode,
              cameraState: _cameraState,
              onSelectionModeChanged: _onSelectionModeChanged,
              onModeTapped: _onModeTapped,
              onVideoRecording: (String? timer) {
                setState(() {
                  _recordingTime = timer;
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

Widget _buildTopActionBar(String? recordingTime, CameraState? state) {
  return ColoredBox(
    color: Colors.black,
    child: recordingTime != null &&
            (state?.captureState?.isRecordingVideo ?? false)
        ? _VideoRecordingTimer(
            isRecordingVideo: (state?.captureState?.isRecordingVideo ?? false),
            time: recordingTime)
        : state != null
            ? TopActionBar(
                state: state,
              )
            : const SizedBox.expand(),
  );
}
