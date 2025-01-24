import 'dart:developer';
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/frame_painter.dart';
import 'package:camerawesome_demo/custom_camera/painters/object_detector_painter.dart';
import 'package:camerawesome_demo/custom_camera/utils/detection_util.dart';

import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
  List<Detection> objDetections = [];
  late Interpreter pballInterpreter;
  late Interpreter fishInterpreter;

  List input = [];
  List output = [];
  bool processing = false;
  bool isLoading = false;
  var interpreterOptions = InterpreterOptions()..threads = 4;
  late IsolateInterpreter pballIsolate;
  late IsolateInterpreter fishIsolate;

  Uint8List? processedFile;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      setState(() {
        isLoading = true;
      });
      pballInterpreter = await Interpreter.fromAsset(
        "assets/ml/pball_model.tflite",
        options: interpreterOptions,
      );
      fishInterpreter = await Interpreter.fromAsset(
        "assets/ml/fish_detection.tflite",
        options: interpreterOptions,
      );

      pballIsolate = await IsolateInterpreter.create(
        address: pballInterpreter.address,
      );
      fishIsolate = await IsolateInterpreter.create(
        address: fishInterpreter.address,
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log('Error loading model: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> detect(Uint8List bytes, isProofball) async {
    await resizeImageToInput(imageBytes: bytes);
    if (isProofball) {
      await pballIsolate.run(input, output);
    } else {
      await fishIsolate.run(input, output);
    }

    final score = output[0][0][4] as double?;
    if (score == null) return;
    double x1 = output[0][0][0];
    double y1 = output[0][0][1];
    double x2 = output[0][0][2];
    double y2 = output[0][0][3];

    log("${output[0][0][0]},${output[0][0][1]},${output[0][0][2]},${output[0][0][3]},${output[0][0][4]}");

    if (score > 0.5) {
      Detection detection = Detection(
        confidence: score,
        rect: Rect.fromPoints(
          Offset(x1, y1),
          Offset(x2, y2),
        ),
      );
      objDetections.add(detection);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> processImage(AnalysisImage image) async {
    if (processing || isLoading) {
      return;
    }

    setState(() {
      processing = true;
    });
    objDetections.clear();

    try {
      await image.when(
        nv21: (Nv21Image img) async {
          await resizeImageToInput(imageBytes: img.bytes);
          await pballIsolate.run(input, output);
        },
        yuv420: (image) async {
          final jpeg = await image.toJpeg();
          processedFile = jpeg.bytes;
        },
        bgra8888: (Bgra8888Image image) async {
          final jpeg = await image.toJpeg();
          processedFile = jpeg.bytes;
        },
        jpeg: (JpegImage img) async {
          await detect(img.bytes, true);
          await detect(img.bytes, false);
        },
      );
    } catch (e) {
      log("error processing image: $e");
    } finally {
      if (mounted) {
        setState(() {
          processing = false;
        });
      }
    }
  }

  Future<void> resizeImageToInput({
    required Uint8List imageBytes,
  }) async {
    try {
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) throw Exception('Failed to load image');

      input = List.generate(
        1,
        (index) => List.generate(
          640,
          (y) => List.generate(
            640,
            (x) => List.generate(
              3,
              (c) {
                final pixel = originalImage.getPixel(x, y);
                double value = c == 0
                    ? pixel.r.toDouble()
                    : c == 1
                        ? pixel.g.toDouble()
                        : pixel.b.toDouble();
                return value / 255.0;
              },
            ),
          ),
        ),
      );

      output = List.filled(1 * 300 * 6, 0).reshape([1, 300, 6]);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      log("Error resizing image: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    pballInterpreter.close();
    pballIsolate.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.mode) {
      FishtechyCameraPreviewMode.photoAndvideo => Scaffold(
          body: CameraAwesomeBuilder.custom(
            onImageForAnalysis: processImage,
            imageAnalysisConfig: AnalysisConfig(
              // 1.
              androidOptions: const AndroidAnalysisOptions.jpeg(
                width: 640,
              ),
              // 2.
              autoStart: true,
              // 3.
              cupertinoOptions: const CupertinoAnalysisOptions.bgra8888(),
              // 4.
              maxFramesPerSecond: 20,
            ),
            builder: (state, preview) {
              widget.onStateChanged(state);
              return Stack(
                children: [
                  //frame
                  CustomPaint(
                    painter: FramePainter(
                      padding: CameraConstants.outerPadding,
                      color: const Color.fromRGBO(0, 5, 34, 0.8), //paint color
                    ),
                    child: Container(
                      margin: CameraConstants.outerPadding,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),

                  if (objDetections.isNotEmpty)
                    ...List.generate(
                      objDetections.length,
                      (index) => BoundaryBoxBorder(
                        rect: DetectionUtils.scaleRectToPreviewArea(
                            previewRect: preview.rect,
                            modelRect: objDetections[index].rect),
                        borderColor: Colors.red,
                        borderWidth: 3,
                      ),
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
      child: Text('3d camera view'),
    );
  }
}

class Detection {
  final double confidence;
  final Rect rect;
  Detection({
    required this.confidence,
    required this.rect,
  });
}
