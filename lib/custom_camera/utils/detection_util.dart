import 'package:flutter/material.dart';

class DetectionUtils {
  static Rect scaleRectToPreviewArea({
    required Rect modelRect,
    required Rect previewRect,
  }) {
    // Extract preview size and position
    final previewWidth = previewRect.width;
    final previewHeight = previewRect.height;

    // Scale the rectangle coordinates
    final scaledLeft = modelRect.left * previewWidth;
    final scaledTop = modelRect.top * previewHeight;
    final scaledRight = modelRect.right * previewWidth;
    final scaledBottom = modelRect.bottom * previewHeight;

    // Return the scaled rectangle
    return Rect.fromPoints(
      Offset(scaledLeft, scaledTop),
      Offset(scaledRight, scaledBottom),
    );
  }
}
