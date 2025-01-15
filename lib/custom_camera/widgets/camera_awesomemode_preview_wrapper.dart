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

import '../utils/file_util.dart';

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
  List<DetectedObject> detectedobj = [];
  Size imageSize = Size.zero;
  InputImageRotation inputImageRotation = InputImageRotation.rotation0deg;

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

    setState(() {
      detectedobj = objects;
      inputImageRotation =
          inputImage.metadata?.rotation ?? InputImageRotation.rotation0deg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.mode) {
      FishtechyCameraPreviewMode.photoAndvideo => Scaffold(
          body: LayoutBuilder(builder: (context, constraint) {
            return CameraAwesomeBuilder.custom(
              onImageForAnalysis: _onImageAnalysis,
              imageAnalysisConfig: AnalysisConfig(
                androidOptions: const AndroidAnalysisOptions.nv21(width: 384),
                cupertinoOptions: const CupertinoAnalysisOptions.bgra8888(),
                autoStart: true,
                maxFramesPerSecond: 20,
              ),
              builder: (state, preview) {
                widget.onStateChanged(state);
                return CustomPaint(
                  // painter: objRect != null && objConfidence > 0.0
                  // ?
                  painter: ObjectDetectorPainter(detectedobj, imageSize,
                      inputImageRotation, preview.isBackCamera)
                  // : null
                  ,
                  child: const CameraContent(),
                );
              },
              onMediaCaptureEvent: _handleMediaCaptureEvent,
              saveConfig: SaveConfig.photoAndVideo(
                initialCaptureMode:
                    widget.cameraMode == FishtechyCameraMode.photo
                        ? CaptureMode.photo
                        : CaptureMode.video,
                photoPathBuilder: _buildPhotoPath,
              ),
            );
          }),
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
