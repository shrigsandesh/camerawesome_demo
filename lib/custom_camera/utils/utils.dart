import 'dart:developer';

import 'package:camerawesome_demo/extensions/mlkit_extension.dart';
import 'package:image/image.dart' as img;

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class YOLOImageProcessor {
  static Future<List<Map<String, dynamic>>> processImage(
    AnalysisImage analysisImage,
    Interpreter interpreter,
  ) async {
    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    log('Input shape: $inputShape'); // e.g., [1, 640, 640, 3]
    log('Output shape: $outputShape');
    // 1. Convert AnalysisImage to input tensor format
    var inputArray = await _preprocessImage(
      analysisImage,
      width: inputShape[1],
      height: inputShape[2],
      channels: inputShape[3],
    );

    // 2. Create output array based on model's output shape
    var outputArray = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(outputShape);

    // 3. Run inference
    interpreter.run(inputArray, outputArray);

    // 4. Process results
    return _processOutput(outputArray[0]); // Process first batch only
  }

  static Future<List<dynamic>> _preprocessImage(
    AnalysisImage image, {
    required int width,
    required int height,
    required int channels,
  }) async {
    // Create input array of dynamic shape
    var input = List.filled(1 * width * height * channels, 0.0)
        .reshape([1, width, height, channels]);

    // Get raw image bytes
    final bytes = image.toInputImage().bytes!;

    // Convert to img.Image for processing
    final img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return input;

    // Resize image to model input dimensions
    final img.Image resizedImage = img.copyResize(
      originalImage,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );

    // Fill input array with normalized pixel values
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    return input;
  }

  static List<Map<String, dynamic>> _processOutput(List<List<double>> output) {
    log(output.toString());
    var recognitions = <Map<String, dynamic>>[];

    for (var detection in output) {
      var confidence = detection[4];

      // Filter by confidence threshold
      if (confidence > 0.5) {
        // Convert normalized coordinates (0-1) to actual coordinates
        var x = detection[0];
        var y = detection[1];
        var w = detection[2];
        var h = detection[3];
        var classId = detection[5].round();

        recognitions.add({
          'bbox': [
            x - w / 2, // Convert from center to top-left
            y - h / 2,
            w,
            h
          ],
          'confidence': confidence,
          'class': classId,
        });
      }
    }

    return recognitions;
  }
}
