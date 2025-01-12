import 'dart:developer';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/frame_painter.dart';

import 'package:camerawesome_demo/custom_camera/widgets/orientation_wrapper.dart';
import 'package:camerawesome_demo/extensions/mlkit_extension.dart';
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
  @override
  Widget build(BuildContext context) {
    return OrientationWrapperWidget(builder: (context, orientation) {
      return CameraAwesomeBuilder.custom(
        onImageForAnalysis: (AnalysisImage img) async {
          // Handle image analysis

          final InputImage inputImage;
          inputImage = img.toInputImage();

          const mode = DetectionMode.stream;

          final options = ObjectDetectorOptions(
              mode: mode, classifyObjects: false, multipleObjects: false);

          final objectDetector = ObjectDetector(options: options);

          final List<DetectedObject> objects =
              await objectDetector.processImage(inputImage);
          log("yeha samma aako xa   .");

          for (DetectedObject detectedObject in objects) {
            final rect = detectedObject.boundingBox;
            final trackingId = detectedObject.trackingId;

            for (Label label in detectedObject.labels) {
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
          return Column(
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
          );
        },
        onMediaCaptureEvent: (mediaCapture) {},
        saveConfig: SaveConfig.photoAndVideo(),
      );
    });
  }
}
