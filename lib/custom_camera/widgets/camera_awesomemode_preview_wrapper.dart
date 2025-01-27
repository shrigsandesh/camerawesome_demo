import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/utils/detector.dart';
import 'package:flutter/material.dart';

import '../constants/camera_constants.dart';
import '../painters/frame_painter.dart';
import '../painters/object_detector_painter.dart';
import '../tflite/ml_processing_result.dart';

class CameraAwesomeModePreviewWrapper extends StatefulWidget {
  const CameraAwesomeModePreviewWrapper({
    super.key,
    required this.mode,
    required this.onStateChanged,
    required this.cameraMode,
  });

  final FishtechyCameraPreviewMode mode;
  final FishtechyCameraMode cameraMode;
  final ValueChanged<CameraState> onStateChanged;

  @override
  State<CameraAwesomeModePreviewWrapper> createState() =>
      _CameraAwesomeModePreviewWrapperState();
}

class _CameraAwesomeModePreviewWrapperState
    extends State<CameraAwesomeModePreviewWrapper> {
  bool isLoadingModel = false;
  Size analysisSize = Size.zero;

  /// Object Detector is running on a background [Isolate]. This is nullable
  /// because acquiring a [Detector] is an asynchronous operation. This
  /// value is `null` until the detector is initialized.
  Detector? _detector;
  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      setState(() {
        isLoadingModel = true;
      });
      Detector.start().then((instance) {
        setState(() {
          _detector = instance;
        });
      });
      setState(() {
        isLoadingModel = false;
      });
    } catch (e) {
      log('Error loading model: $e');
      setState(() {
        isLoadingModel = false;
      });
    }
  }

  Future<void> runDetectionOnImage(AnalysisImage analysisImage) async {
    _detector?.processFrame(analysisImage);
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.mode) {
      FishtechyCameraPreviewMode.photoAndvideo => Scaffold(
          body: CameraAwesomeBuilder.custom(
            onImageForAnalysis: runDetectionOnImage,
            imageAnalysisConfig: AnalysisConfig(
              androidOptions: const AndroidAnalysisOptions.yuv420(
                width: 224,
              ),
              autoStart: true,
              cupertinoOptions: const CupertinoAnalysisOptions.bgra8888(),
              maxFramesPerSecond: 1,
            ),
            builder: (state, preview) {
              widget.onStateChanged(state);
              return Stack(
                children: [
                  Stack(
                    children: [
                      CustomPaint(
                        painter: FramePainter(
                          padding: CameraConstants.outerPadding,
                          color: const Color.fromRGBO(0, 5, 34, 0.8),
                        ),
                        child: Container(
                          margin: CameraConstants.outerPadding,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10.0),
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
                                        renderSize: preview.previewSize),
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
                ],
              );
            },
            saveConfig: SaveConfig.photoAndVideo(
              initialCaptureMode: widget.cameraMode == FishtechyCameraMode.photo
                  ? CaptureMode.photo
                  : CaptureMode.video,
            ),
          ),
        ),
      FishtechyCameraPreviewMode.threeD => const _3DCameraWidget(),
    };
  }
}

// ignore: camel_case_types
class _3DCameraWidget extends StatelessWidget {
  const _3DCameraWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('3D Camera View'),
    );
  }
}
