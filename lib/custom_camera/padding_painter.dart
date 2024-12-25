import 'package:flutter/material.dart';

class PaddingPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final EdgeInsets padding;
  final Color borderColor;
  final double borderWidth;

  PaddingPainter({
    required this.color,
    required this.borderRadius,
    required this.padding,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Create paths for the outer and inner rectangles
    // Outer rectangle has no border radius
    final outerRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.zero, // No border radius for outer rectangle
    );

    // Inner rectangle with border radius
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        padding.left,
        padding.top,
        size.width - padding.right,
        size.height - padding.bottom,
      ),
      Radius.circular(borderRadius),
    );

    // Create a path that represents the padding area
    final path = Path()
      ..addRRect(outerRect)
      ..addRRect(innerRect);

    // Use the even-odd fill type to create the padding area
    path.fillType = PathFillType.evenOdd;

    // Draw the padding area
    canvas.drawPath(path, fillPaint);

    // Draw the inner border
    canvas.drawRRect(innerRect, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is PaddingPainter) {
      return oldDelegate.color != color ||
          oldDelegate.borderRadius != borderRadius ||
          oldDelegate.padding != padding ||
          oldDelegate.borderColor != borderColor ||
          oldDelegate.borderWidth != borderWidth;
    }
    return true;
  }
}
