import 'package:flutter/material.dart';
import 'dart:math' as math;

class BoundingBoxCoordinatesTranslator {
  final Size imageSize;
  final Size screenSize;
  final EdgeInsets padding;

  BoundingBoxCoordinatesTranslator({
    required this.imageSize,
    required this.screenSize,
    this.padding = EdgeInsets.zero,
  });

  Rect translateRect(Rect rect) {
    // Calculate scale factors
    final double scaleX =
        (screenSize.width - padding.left - padding.right) / imageSize.width;
    final double scaleY =
        (screenSize.height - padding.top - padding.bottom) / imageSize.height;

    // Use the smaller scale to maintain aspect ratio
    final double scale = math.min(scaleX, scaleY);

    // Calculate translation to center the image
    final double offsetX =
        (screenSize.width - (imageSize.width * scale)) / 2 + padding.left;
    final double offsetY =
        (screenSize.height - (imageSize.height * scale)) / 2 + padding.top;

    return Rect.fromLTRB(
      rect.left * scale + offsetX,
      rect.top * scale + offsetY,
      rect.right * scale + offsetX,
      rect.bottom * scale + offsetY,
    );
  }
}

// Modify your ObjectDetectorPainter
class ObjectDetectorPainter extends CustomPainter {
  final Rect rect;
  final String label;
  final double confidence;
  final Size imageSize;
  final Size screenSize;
  final EdgeInsets padding;

  ObjectDetectorPainter({
    required this.rect,
    required this.label,
    required this.confidence,
    required this.imageSize,
    required this.screenSize,
    this.padding = EdgeInsets.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final translator = BoundingBoxCoordinatesTranslator(
      imageSize: imageSize,
      screenSize: screenSize,
      padding: padding,
    );

    final scaledRect = translator.translateRect(rect);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    canvas.drawRect(scaledRect, paint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label (${(confidence * 100).toStringAsFixed(0)}%)',
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(scaledRect.left, scaledRect.top - 20),
    );
  }

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) => true;
}
