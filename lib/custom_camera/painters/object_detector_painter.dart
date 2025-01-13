import 'package:flutter/material.dart';

class ObjectDetectorPainter extends CustomPainter {
  final Rect rect;
  final String label; // Add label parameter
  final double confidence; // Add confidence parameter

  ObjectDetectorPainter({
    required this.rect,
    required this.label,
    required this.confidence,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final double scaleY = size.height / 384;

    final Rect scaledRect = Rect.fromLTRB(
      rect.left,
      rect.top * scaleY,
      rect.right,
      rect.bottom * scaleY,
    );

    canvas.drawRect(scaledRect, paint);

    // Draw label text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label ${(confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.red,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Position text above the rect
    textPainter.paint(
      canvas,
      Offset(scaledRect.left, scaledRect.top * scaleY - textPainter.height - 8),
    );

    // Rest of your corner drawing code...
  }

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) {
    return oldDelegate.rect != rect ||
        oldDelegate.label != label ||
        oldDelegate.confidence != confidence;
  }
}
