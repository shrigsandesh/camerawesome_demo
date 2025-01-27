import 'dart:math';

import 'package:camera/camera.dart';
import 'package:camerawesome_demo/custom_camera/painters/object_detector_painter.dart';
import 'package:camerawesome_demo/custom_camera/tflite/ml_processing_result.dart';
import 'package:camerawesome_demo/custom_camera/utils/detector_camera.dart';
import 'package:flutter/material.dart';

class CameraUsingCamera extends StatelessWidget {
  const CameraUsingCamera({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: CameraUsingCameraPreview(),
    );
  }
}

class CameraUsingCameraPreview extends StatefulWidget {
  const CameraUsingCameraPreview({super.key});

  @override
  State<CameraUsingCameraPreview> createState() =>
      _CameraUsingCameraPreviewState();
}

class _CameraUsingCameraPreviewState extends State<CameraUsingCameraPreview>
    with WidgetsBindingObserver {
  late List<CameraDescription> cameras;

  Detector? _detector;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initStateAsync();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _detector?.stop();
    super.dispose();
  }

  void _initStateAsync() async {
    _initializeCamera();

    Detector.start().then((instance) {
      setState(() {
        _detector = instance;
      });
    });
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      cameras[0],
      // Define the resolution to use.
      ResolutionPreset.high,
    )..initialize().then((_) {
        _controller?.startImageStream(onLatestImageAvailable);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller == null
        ? const SizedBox.shrink()
        : ValueListenableBuilder<CameraValue>(
            valueListenable: _controller!,
            builder: (context, value, _) {
              final mediaSize = MediaQuery.of(context).size;
              if (!value.isInitialized) {
                return const SizedBox.shrink();
              }
              final aspectRatio = 1 / value.aspectRatio;

              return Stack(
                children: [
                  AspectRatio(
                    aspectRatio: aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                  BoundaryBoxBorder(
                    rect: Rect.fromLTWH(
                      0,
                      0,
                      mediaSize.width,
                      mediaSize.width / aspectRatio,
                    ),
                    borderColor: Colors.red,
                    borderWidth: 2,
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
                                    mediaSize.width,
                                    mediaSize.width / aspectRatio,
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
              );
            },
          );
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _controller?.stopImageStream();
        _detector?.stop();
        break;
      case AppLifecycleState.resumed:
        _initStateAsync();
        break;
      default:
    }
  }
}

/// Singleton to record size related data
class ScreenParams {
  static late Size screenSize;
  static late Size previewSize;

  static double previewRatio = max(previewSize.height, previewSize.width) /
      min(previewSize.height, previewSize.width);

  static Size screenPreviewSize =
      Size(screenSize.width, screenSize.width * previewRatio);
}
