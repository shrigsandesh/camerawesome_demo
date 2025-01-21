import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/frame_painter.dart';

import 'package:camerawesome_demo/custom_camera/widgets/orientation_wrapper.dart';
import 'package:camerawesome_demo/extensions/mlkit_extension.dart';
import 'package:camerawesome_demo/services/file_util.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
  late Interpreter pballInterpreter;
  List input = [];
  List output = [];
  bool processing = false;

  Uint8List? processedFile;

  Future<void> processImage(AnalysisImage image) async {
    if (processing) {
      return;
    }
    setState(() {
      processing = true;
    });
    try {
      image.when(
        nv21: (Nv21Image image) {
          Uint8List rgbaData =
              convertNV21ToBytes(image.width, image.height, image.bytes);

          pballInterpreter = Interpreter.fromBuffer(rgbaData);
          resizeImageToInput(imageBytes: rgbaData);
          pballInterpreter.run(input, output);
        },
        yuv420: (image) {
          image.toJpeg().then((jpeg) {
            processedFile = jpeg.bytes;
          });
        },
        bgra8888: (Bgra8888Image image) {
          image.toJpeg().then((jpeg) {
            processedFile = jpeg.bytes;
          });
        },
        jpeg: (JpegImage image) {
          processedFile = image.bytes;
        },
      );
    } catch (e) {
      log("error processing image: $e");
    }
  }

  Future<void> resizeImageToInput({
    required Uint8List imageBytes,
  }) async {
    // Decode the Uint8List directly using img.decodeImage
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) throw Exception('Failed to load image');

    // Resize image to 640x640
    final resizedImage = img.copyResize(
      originalImage,
      width: 640,
      height: 640,
      interpolation: img.Interpolation.linear,
    );

    // Create input tensor
    input = List.generate(
      1,
      (index) => List.generate(
        640,
        (y) => List.generate(
          640,
          (x) => List.generate(
            3,
            (c) {
              final pixel = resizedImage.getPixel(x, y);
              double value = 0;
              if (c == 0) {
                value = pixel.r.toDouble();
              } else if (c == 1) {
                value = pixel.g.toDouble();
              } else {
                value = pixel.b.toDouble();
              }
              return value / 255.0;
            },
          ),
        ),
      ),
    );
    output = List.filled(1 * 300 * 6, 0).reshape([1, 300, 6]);
    log(output.first[0].toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OrientationWrapperWidget(builder: (context, orientation) {
      return LayoutBuilder(builder: (context, constraint) {
        return CameraAwesomeBuilder.custom(
          onImageForAnalysis: processImage,
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
            maxFramesPerSecond: 5,
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
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
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
    });
  }
}
