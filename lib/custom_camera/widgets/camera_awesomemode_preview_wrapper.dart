import 'dart:developer';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/object_detector_painter.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_content.dart';
import 'package:camerawesome_demo/extensions/mlkit_extension.dart';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/file_util.dart';

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
  Rect? objRect;
  String objLabel = '';
  double objConfidence = 0.0;
  Size imageSize = Size.zero;

  /// Handles image analysis and object detection.
  Future<void> _onImageAnalysis(AnalysisImage img) async {
    // Update image dimensions
    setState(() {
      imageSize = Size(img.width.toDouble(), img.height.toDouble());
    });

    // Convert the analysis image to an ML Kit-compatible format
    final inputImage = img.toInputImage();

    // Load the object detection model
    final modelPath =
        await getModelPath('assets/ml/object_labeler_flowers.tflite');
    final options = LocalObjectDetectorOptions(
      modelPath: modelPath,
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: false,
    );

    final objectDetector = ObjectDetector(options: options);

    // Perform object detection
    final List<DetectedObject> objects =
        await objectDetector.processImage(inputImage);
    log('Detected objects: ${objects.length}');

    for (DetectedObject detectedObject in objects) {
      // Log detected bounding box
      final rect = detectedObject.boundingBox;
      log("Bounding Box: ${rect.left}, ${rect.top}, ${rect.right}, ${rect.bottom}");

      objRect = rect;

      for (Label label in detectedObject.labels) {
        setState(() {
          objLabel = label.text;
          objConfidence = label.confidence;
        });
        log('Label: ${label.text}, Confidence: ${label.confidence}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.mode) {
      FishtechyCameraPreviewMode.photoAndvideo => Scaffold(
          body: CameraAwesomeBuilder.custom(
            onImageForAnalysis: _onImageAnalysis,
            imageAnalysisConfig: AnalysisConfig(
              androidOptions: const AndroidAnalysisOptions.nv21(width: 250),
              cupertinoOptions: const CupertinoAnalysisOptions.bgra8888(),
              autoStart: true,
              maxFramesPerSecond: 20,
            ),
            builder: (state, preview) {
              widget.onStateChanged(state);
              return CustomPaint(
                painter: objRect != null && objConfidence > 0.0
                    ? ObjectDetectorPainter(
                        rect: objRect!,
                        label: objLabel,
                        confidence: objConfidence,
                        imageSize: imageSize,
                        screenSize: MediaQuery.of(context).size,
                        padding: CameraConstants.outerPadding,
                      )
                    : null,
                child: const CameraContent(),
              );
            },
            onMediaCaptureEvent: _handleMediaCaptureEvent,
            saveConfig: SaveConfig.photoAndVideo(
              initialCaptureMode: widget.cameraMode == FishtechyCameraMode.photo
                  ? CaptureMode.photo
                  : CaptureMode.video,
              photoPathBuilder: _buildPhotoPath,
            ),
          ),
        ),
      FishtechyCameraPreviewMode.threeD => const _3DCameraWidget(),
    };
  }

  /// Handles saving captured media (photos/videos) to the gallery.
  Future<void> _handleMediaCaptureEvent(MediaCapture media) async {
    if (media.captureRequest.path != null) {
      if (media.isPicture) {
        await Gal.putImage(media.captureRequest.path!, album: "Fishtechy");
      } else if (media.isVideo) {
        await Gal.putVideo(media.captureRequest.path!, album: "Fishtechy");
      }
    }
  }

  /// Builds the path for saving captured photos.
  Future<CaptureRequest> _buildPhotoPath(List<Sensor> sensors) async {
    final Directory extDir = await getTemporaryDirectory();
    final Directory testDir =
        await Directory('${extDir.path}/camerawesome').create(recursive: true);

    if (sensors.length == 1) {
      final String filePath =
          '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      log("Photo saved at: $filePath");
      return SingleCaptureRequest(filePath, sensors.first);
    }

    // Handle multiple sensors (e.g., front and back cameras)
    return MultipleCaptureRequest({
      for (final sensor in sensors)
        sensor:
            '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : 'back_'}${DateTime.now().millisecondsSinceEpoch}.jpg',
    });
  }
}

class _3DCameraWidget extends StatelessWidget {
  const _3DCameraWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('3D Camera View'),
    );
  }
}
