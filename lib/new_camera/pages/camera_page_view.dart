import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/frame_painter.dart';
import 'package:camerawesome_demo/custom_camera/painters/object_detector_painter.dart';
import 'package:camerawesome_demo/custom_camera/tflite/ml_processing_result.dart';
import 'package:camerawesome_demo/custom_camera/utils/detector_camera.dart';
import 'package:camerawesome_demo/new_camera/widgets/bottom_action_bar.dart';
import 'package:camerawesome_demo/new_camera/widgets/top_action_bar.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPageView extends StatefulWidget {
  const CameraPageView({super.key});

  @override
  State<CameraPageView> createState() => _CameraPageViewState();
}

class _CameraPageViewState extends State<CameraPageView> {
  late CameraController _cameraController;
  late PageController _pageController;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;
  List<FishtechyCameraMode> availableModes = <FishtechyCameraMode>[];
  late PageController modePageController;
  FishtechyCameraMode _selectedMode = FishtechyCameraMode.photo;
  Detector? _detector;
  String? recordingTime;

  @override
  void initState() {
    super.initState();

    availableModes = [
      FishtechyCameraMode.photo,
      FishtechyCameraMode.video,
    ];
    _pageController = PageController();
    modePageController = PageController(viewportFraction: 0.25, initialPage: 0);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      Detector.start().then((instance) {
        setState(() {
          _detector = instance;
        });
      });
      _cameras = await availableCameras();

      _cameraController = CameraController(
        _cameras[0],
        enableAudio: true,
        ResolutionPreset.medium,
      );

      _cameraController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }

        _cameraController.startImageStream(onLatestImageAvailable);
      });
    } catch (e) {
      log('Error initializing camera: $e');
    }
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    modePageController.dispose();
    _pageController.dispose();
    _detector?.stop();
    super.dispose();
  }

  void _onSelectionModeChanged({
    required FishtechyCameraMode mode,
    required bool updateMode,
    required bool updatePage,
  }) {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedMode = mode;
    });
    if (updatePage) {
      _pageController.animateToPage(
        mode.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
    if (updateMode) {
      modePageController.animateToPage(
        mode.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            ExpandablePageView(
              onPageChanged: (index) {
                _onSelectionModeChanged(
                  mode: availableModes[index],
                  updateMode: true,
                  updatePage: true,
                );
              },
              controller: _pageController,
              children: availableModes
                  .map((e) => switch (e) {
                        FishtechyCameraMode.photo ||
                        FishtechyCameraMode.video =>
                          CameraStackedPreview(
                            key: ValueKey(e),
                            cameraController: _cameraController,
                            stream: _detector?.resultsStream.stream,
                            selectedMode: _selectedMode,
                            recordingTime: recordingTime,
                          ),
                        FishtechyCameraMode.threeD => const SizedBox(
                            height: 500,
                          ),
                      })
                  .toList(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BottomActionBar(
                modePgController: modePageController,
                availableModes: availableModes,
                selectedMode: _selectedMode,
                onModeChanged: (mode) {
                  _onSelectionModeChanged(
                    mode: mode,
                    updateMode: true,
                    updatePage: true,
                  );
                },
                onVideoRecording: (String? timer) {
                  setState(() {
                    recordingTime = timer;
                  });
                },
                onVideoStopped: () {},
                controller: _cameraController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraStackedPreview extends StatefulWidget {
  const CameraStackedPreview({
    super.key,
    required this.cameraController,
    this.stream,
    this.recordingTime,
    required this.selectedMode,
  });
  final CameraController cameraController;
  final Stream<MlProcessingResult>? stream;
  final String? recordingTime;
  final FishtechyCameraMode selectedMode;
  @override
  State<CameraStackedPreview> createState() => _CameraStackedPreviewState();
}

class _CameraStackedPreviewState extends State<CameraStackedPreview> {
  final GlobalKey _cameraPreviewWindowKey = GlobalKey();
  final GlobalKey _globalStackKey = GlobalKey();
  Rect? detectionWindowRect;
  Size stackSize = Size.zero;
  Timer? _retryTimer;
  final int maxRetries = 100;
  int currentRetry = 0;
  bool isWindowSizeDetermined = false;

  @override
  void initState() {
    super.initState();
    startUntilWindowRectDetermined();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void startUntilWindowRectDetermined() {
    _retryTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (isWindowSizeDetermined || currentRetry >= maxRetries) {
        _retryTimer?.cancel();
      } else {
        determineGoodWindowRect();
        currentRetry++;
      }
    });
  }

  void determineGoodWindowRect() {
    final previewBoundObj =
        _globalStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (previewBoundObj == null) return;
    stackSize = previewBoundObj.size;
    final goodRect = _cameraPreviewWindowKey.globalPaintBounds(previewBoundObj);
    if (goodRect == null) return;
    setState(() {
      isWindowSizeDetermined = true;
      detectionWindowRect = goodRect;
    });
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = 1 / widget.cameraController.value.aspectRatio;
    return Column(
      children: [
        TopActionBar(
          recordingTime: widget.recordingTime,
          selectedMode: widget.selectedMode,
          controller: widget.cameraController,
        ),
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            key: _globalStackKey,
            children: [
              RotatedBox(
                quarterTurns: Platform.isAndroid ? 1 : 0,
                child: CameraPreview(
                  widget.cameraController,
                ),
              ),
              CustomPaint(
                painter: FramePainter(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 40.0,
                  ),
                  color: const Color.fromRGBO(0, 5, 34, 0.8),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 40.0,
                  ),
                  child: Stack(
                    key: _cameraPreviewWindowKey,
                    fit: StackFit.expand,
                    children: [
                      if (detectionWindowRect != null) ...[
                        StreamBuilder<MlProcessingResult>(
                          stream: widget.stream,
                          builder: (context, snapshot) {
                            // If there's no data yet, show a loading indicator or a placeholder
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final result = snapshot.data as MlProcessingResult;
                            final detectionStatus = result.getDetectionStatuses(
                              containerRect: detectionWindowRect!,
                              renderSize: stackSize,
                            );
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 18.0),
                                margin: const EdgeInsets.only(bottom: 10.0),
                                color: switch (detectionStatus) {
                                  MlRecognitionWindowStatus.allGood =>
                                    Colors.green,
                                  _ => Colors.red,
                                },
                                child: Text(
                                  detectionStatus.message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                stream: widget.stream,
                builder: (context, snapshot) {
                  // If there's no data yet, show a loading indicator or a placeholder
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final result = snapshot.data as MlProcessingResult;

                  return Stack(
                    children: [
                      if (result.recognitions.isNotEmpty)
                        for (final recognition in result.recognitions)
                          BoundaryBoxBorder(
                            rect: recognition.renderRect(
                              renderSize: stackSize,
                            ),
                            borderColor: Colors.red,
                            borderWidth: 2,
                          ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension GlobalKeyExtension on GlobalKey {
  Rect? globalPaintBounds(RenderObject? ancestor) {
    final renderObject = currentContext?.findRenderObject();
    if (renderObject != null) {
      final translation =
          renderObject.getTransformTo(ancestor).getTranslation();
      final offset = Offset(translation.x, translation.y);
      return renderObject.paintBounds.shift(offset);
    }
    return null;
  }
}
