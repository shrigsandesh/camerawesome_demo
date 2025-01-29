import 'dart:math';

import 'package:camera/camera.dart';
import 'package:camerawesome_demo/custom_camera/painters/object_detector_painter.dart';
import 'package:camerawesome_demo/custom_camera/tflite/ml_processing_result.dart';
import 'package:camerawesome_demo/custom_camera/utils/detector_camera.dart';
import 'package:flutter/material.dart';

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
  bool isRecording = false;
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
        _controller!.startImageStream(onLatestImageAvailable);
        setState(() {});
      });
  }

  Future<void> startVideoRecording() async {
    setState(() {
      isRecording = true;
    });
    await _controller!.startVideoRecording(onAvailable: onLatestImageAvailable);
  }

  Future<void> stopVideoRecording() async {
    setState(() {
      isRecording = false;
    });
    final file = await _controller!.stopVideoRecording();
    _controller!.startImageStream(onLatestImageAvailable);
    print("SAVED TO ${file.path}");
  }

  Future<void> takePicture() async {
    final file = await _controller!.takePicture();
    print("SAVED TO ${file.path}");
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return (_controller == null || !_controller!.value.isInitialized)
        ? const SizedBox.shrink()
        : Scaffold(
            backgroundColor: Colors.black,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (isRecording) {
                  stopVideoRecording();
                } else {
                  startVideoRecording();
                }
              },
              child: Icon(
                isRecording
                    ? Icons.stop_circle
                    : Icons.fiber_manual_record_rounded,
              ),
            ),
            body: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1 / _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
                BoundaryBoxBorder(
                  rect: Rect.fromLTWH(
                    0,
                    0,
                    mediaSize.width,
                    mediaSize.width * _controller!.value.aspectRatio,
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
                                  mediaSize.width *
                                      _controller!.value.aspectRatio,
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
            ));
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    _detector?.processFrame(cameraImage);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initStateAsync();
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
