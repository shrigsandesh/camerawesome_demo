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
  Size imageSize = Size.zero;
  @override
  Widget build(BuildContext context) {
    return OrientationWrapperWidget(builder: (context, orientation) {
      return LayoutBuilder(builder: (context, constraint) {
        final screenSize = Size(constraint.maxWidth, constraint.maxHeight);

        log("layout height ${constraint.maxHeight}");
        log("layout width ${constraint.maxWidth}");

        return CameraAwesomeBuilder.custom(
          onImageForAnalysis: (AnalysisImage img) async {
            setState(() {
              imageSize = Size(img.width.toDouble(), img.height.toDouble());
            });

            // Handle image analysis
            log("original height  ${img.height}");
            log("original width  ${img.width}");

            final InputImage inputImage;
            inputImage = img.toInputImage();

            final modelPath =
                await getModelPath('assets/ml/object_labeler_flowers.tflite');

            final options = LocalObjectDetectorOptions(
                modelPath: modelPath,
                mode: DetectionMode.stream,
                classifyObjects: true,
                multipleObjects: false);

            final objectDetector = ObjectDetector(options: options);

            final List<DetectedObject> objects =
                await objectDetector.processImage(inputImage);

            log(objects.length.toString());

            for (DetectedObject detectedObject in objects) {
              final rect = detectedObject.boundingBox;
              // final trackingId = detectedObject.trackingId;
              log("rect : ${rect.left},${rect.top},${rect.right},${rect.bottom}");

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
              painter: objRect != null && objConfidence != 0.0
                  ? ObjectDetectorPainter(
                      rect: objRect!,
                      label: objLabel,
                      confidence: objConfidence,
                      imageSize: imageSize,
                      screenSize: screenSize,
                      padding: CameraConstants.outerPadding,
                    )
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
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
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
    });
  }
}
