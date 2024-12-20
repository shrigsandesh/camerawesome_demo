import 'dart:ui';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

extension MLKitUtils on AnalysisImage {
  InputImage toInputImage() {
    return when(
      nv21: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            rotation: _convertRotation(rotation),
            format: InputImageFormat.nv21,
            size: Size(width.toDouble(), height.toDouble()),
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
      bgra8888: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            rotation: _convertRotation(rotation),
            format: InputImageFormat.bgra8888,
            size: Size(width.toDouble(), height.toDouble()),
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
    )!;
  }

  // Generic rotation conversion method
  InputImageRotation _convertRotation(dynamic rotation) {
    // If rotation is an enum, you might need to match its exact name
    // This is a fallback method
    String rotationString = rotation.toString().split('.').last;

    switch (rotationString) {
      case '0':
      case 'rotation0':
        return InputImageRotation.rotation0deg;
      case '90':
      case 'rotation90':
        return InputImageRotation.rotation90deg;
      case '180':
      case 'rotation180':
        return InputImageRotation.rotation180deg;
      case '270':
      case 'rotation270':
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  InputImageFormat get inputImageFormat {
    switch (format) {
      case InputAnalysisImageFormat.bgra8888:
        return InputImageFormat.bgra8888;
      case InputAnalysisImageFormat.nv21:
        return InputImageFormat.nv21;
      default:
        return InputImageFormat.yuv420;
    }
  }
}
