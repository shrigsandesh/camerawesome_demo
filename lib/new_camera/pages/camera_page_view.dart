import 'dart:developer';

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
  final GlobalKey _cameraPreviewWindowKey = GlobalKey();
  final GlobalKey _globalStackKey = GlobalKey();

  Rect? containerRect;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateContainerRect();
    });
    availableModes = [
      FishtechyCameraMode.photo,
      FishtechyCameraMode.video,
    ];
    _pageController = PageController();
    modePageController = PageController(viewportFraction: 0.25, initialPage: 0);
    _initializeCamera();
  }

  void _updateContainerRect() {
    setState(() {
      containerRect = _cameraPreviewWindowKey.globalPaintBounds(
        _globalStackKey.currentContext?.findRenderObject(),
      );
    });
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
        ResolutionPreset.high,
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

    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const Spacer(),
          TopActionBar(
            recordingTime: recordingTime,
            selectedMode: _selectedMode,
            controller: _cameraController,
          ),
          const Spacer(
            flex: 2,
          ),
          Center(
            child: ExpandablePageView(
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
                          buildPreview(
                            screenSize: screenSize,
                          ),
                        FishtechyCameraMode.threeD => const SizedBox(
                            height: 500,
                          ),
                      })
                  .toList(),
            ),
          ),
          const Spacer(
            flex: 3,
          ),
          BottomActionBar(
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
            onVideoStopped: () {
              setState(() {
                recordingTime = null;
              });
            },
            controller: _cameraController,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget buildPreview({
    required Size screenSize,
  }) {
    return AspectRatio(
      aspectRatio: 1 / _cameraController.value.aspectRatio,
      child: Stack(
        key: _globalStackKey,
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController),
          CustomPaint(
            painter: FramePainter(
              padding: CameraConstants.outerPadding,
              color: const Color.fromRGBO(0, 5, 34, 0.8),
            ),
            child: Container(
              margin: CameraConstants.outerPadding,
              child: Stack(
                children: [
                  StreamBuilder(
                      stream: _detector?.resultsStream.stream,
                      builder: (context, snapshot) {
                        // If there's no data yet, show a loading indicator or a placeholder
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final result = snapshot.data as MlProcessingResult;
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.black26,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              result.getDetectionStatus(
                                containerRect: containerRect!,
                                renderSize: Size(
                                  screenSize.width,
                                  screenSize.width *
                                      _cameraController.value.aspectRatio,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
          StreamBuilder(
            stream: _detector?.resultsStream.stream,
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
                          renderSize: Size(
                            screenSize.width,
                            screenSize.width *
                                _cameraController.value.aspectRatio,
                          ),
                        ),
                        borderColor: Colors.red,
                        borderWidth: 2,
                      ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 50,
                      ),
                      color: Colors.black26,
                      child: Text(
                        result.stats.toString(),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
