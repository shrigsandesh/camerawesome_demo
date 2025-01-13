import 'dart:developer';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/frame_painter.dart';
import 'package:camerawesome_demo/custom_camera/painters/object_detector_painter.dart';

import 'package:camerawesome_demo/custom_camera/widgets/orientation_wrapper.dart';
import 'package:camerawesome_demo/extensions/mlkit_extension.dart';
import 'package:camerawesome_demo/services/file_util.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class CameraContent extends StatefulWidget {
  const CameraContent({
    super.key,
    this.showInstruction = true,
  });

  final bool showInstruction;

  @override
  State<CameraContent> createState() => _CameraContentState();
}

class _CameraContentState extends State<CameraContent> {
  Rect? objRect;
  String objLabel = '';
  double objConfidence = 0.0;
  @override
  Widget build(BuildContext context) {
    return OrientationWrapperWidget(builder: (context, orientation) {
      return CameraAwesomeBuilder.custom(
        onImageForAnalysis: (AnalysisImage img) async {
          // Handle image analysis

          final InputImage inputImage;
          inputImage = img.toInputImage();

          final modelPath =
              await getModelPath('assets/ml/fish_detection.tflite');

          final options = LocalObjectDetectorOptions(
              modelPath: modelPath,
              mode: DetectionMode.stream,
              classifyObjects: false,
              multipleObjects: false);

          final objectDetector = ObjectDetector(options: options);

          final List<DetectedObject> objects =
              await objectDetector.processImage(inputImage);

          for (DetectedObject detectedObject in objects) {
            final rect = detectedObject.boundingBox;
            // final trackingId = detectedObject.trackingId;

            objRect = rect;
            for (Label label in detectedObject.labels) {
              setState(() {
                objLabel = label.text;
                objConfidence = label.confidence;
              });
              log('${label.text} ${label.confidence}');
            }
          }
        },
        imageAnalysisConfig: AnalysisConfig(
          // 1.
          androidOptions: const AndroidAnalysisOptions.nv21(
            width: 250,
          ),
          // 2.
          autoStart: true,
          // 3.
          cupertinoOptions: const CupertinoAnalysisOptions.bgra8888(),
          // 4.
          maxFramesPerSecond: 20,
        ),
        builder: (state, preview) {
          return CustomPaint(
            painter: objRect != null
                ? ObjectDetectorPainter(
                    rect: objRect!, label: objLabel, confidence: objConfidence)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //camera section
                Expanded(
                  flex: 15,
                  child: !widget.showInstruction
                      ? const SizedBox()
                      : Stack(
                          children: [
                            //frame
                            CustomPaint(
                              painter: FramePainter(
                                padding: CameraConstants.outerPadding,
                                color: const Color.fromRGBO(
                                    0, 5, 34, 0.8), //paint color
                              ),
                              child: Container(
                                margin: CameraConstants.outerPadding,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
        onMediaCaptureEvent: (mediaCapture) {},
        saveConfig: SaveConfig.photoAndVideo(),
      );
    });
  }
}
