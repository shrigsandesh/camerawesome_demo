import 'package:flutter/material.dart';

class FramePainter extends CustomPainter {
  final Color color;
  final EdgeInsets padding;
  final Color lineColor;
  final double lineWidth;
  final double dotRadius;
  final List<Color> lineGradientColors;

  FramePainter({
    required this.color,
    required this.padding,
    this.lineColor = Colors.blue,
    this.lineWidth = 3.0,
    this.dotRadius = 4.0,
    this.lineGradientColors = const [
      Color.fromRGBO(82, 176, 255, 1),
      Color.fromRGBO(186, 223, 255, 1)
    ],
  });
  Paint _createLinePaint(Offset start, Offset end) {
    // Create gradient paint
    return Paint()
      ..shader = LinearGradient(
        colors: lineGradientColors,
        begin: Alignment(start.dx / end.dx, start.dy / end.dy),
        end: Alignment(end.dx / start.dx, end.dy / start.dy),
      ).createShader(Rect.fromPoints(start, end))
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
  }

  void _drawDot(Canvas canvas, Offset position) {
    final Paint dotPaint = Paint()
      ..color = const Color.fromRGBO(82, 176, 255, 1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, dotRadius, dotPaint);
  }

  void _drawCornerLines(Canvas canvas, Size size) {
    final Paint secondaryLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final Paint secondaryDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Calculate responsive spacing for double lines
    final double lineOffset = lineWidth / 2;
    final double topSpacing = padding.top / 4;
    final double bottomSpacing = padding.bottom / 4;

    // Top section
    if (padding.left > 0 && padding.top > 0) {
      final leftX = padding.left / 2;
      final topY = padding.top / 2 - topSpacing;

      // Vertical lines
      // line: 1
      canvas.drawLine(
        Offset(leftX, topY),
        Offset(leftX, size.height * 0.2),
        _createLinePaint(Offset(leftX, topY), Offset(leftX, size.height * 0.2)),
      );
      // line: 4
      canvas.drawLine(
        Offset(size.width - padding.right / 2, topY + topSpacing),
        Offset(size.width - padding.right / 2, size.height * 0.5),
        _createLinePaint(
          Offset(size.width - padding.right / 2, topY + topSpacing),
          Offset(size.width - padding.right / 2, size.height * 0.5),
        ),
      );

      // Double horizontal lines
      // line: 2
      canvas.drawLine(
        Offset(leftX - lineOffset, topY),
        Offset(size.width - padding.right / 2, topY),
        _createLinePaint(
          Offset(leftX - lineOffset, topY),
          Offset(size.width - padding.right / 2, topY),
        ),
      );

      //  line: 3
      canvas.drawLine(
        Offset(padding.left, topY + topSpacing),
        Offset(size.width - padding.right / 2, topY + topSpacing + lineOffset),
        _createLinePaint(
          Offset(padding.left, topY + topSpacing),
          Offset(
              size.width - padding.right / 2, topY + topSpacing + lineOffset),
        ),
      );

      // Dots
      // dot: 1
      _drawDot(canvas, Offset(leftX, size.height * 0.2));
      // dot: 2
      _drawDot(
        canvas,
        Offset(size.width - padding.right / 2, topY),
      );
      // dot:3
      _drawDot(
        canvas,
        Offset(size.width - padding.right / 2, size.height * 0.5),
      );
    }

    // Bottom section
    if (padding.left > 0 && padding.bottom > 0) {
      final leftX = padding.left / 2;
      final bottomY = size.height - padding.bottom / 2 + bottomSpacing;

      // Vertical lines
      // line: 6
      canvas.drawLine(
        Offset(
            size.width - padding.right / 2, size.height * 0.6 + dotRadius * 2),
        Offset(size.width - padding.right / 2, bottomY),
        _createLinePaint(
          Offset(size.width - padding.right / 2,
              size.height * 0.6 + dotRadius * 2),
          Offset(size.width - padding.right / 2, bottomY),
        ),
      );

      // Double horizontal lines
      // line: 7
      canvas.drawLine(
        Offset(leftX, bottomY),
        Offset(size.width - padding.right / 2 + lineOffset, bottomY),
        _createLinePaint(
          Offset(leftX, bottomY),
          Offset(size.width - padding.right / 2 + lineOffset, bottomY),
        ),
      );
      // line: 8
      canvas.drawLine(
        Offset(leftX - lineOffset, bottomY - bottomSpacing),
        Offset(size.width - padding.right, bottomY - bottomSpacing),
        _createLinePaint(
          Offset(leftX - lineOffset, bottomY - bottomSpacing),
          Offset(size.width - padding.right, bottomY - bottomSpacing),
        ),
      );

      // Dots
      // dot: 4
      _drawDot(
        canvas,
        Offset(
            size.width - padding.right / 2, size.height * 0.6 + dotRadius * 2),
      );
      // dot: 5
      _drawDot(
        canvas,
        Offset(
            padding.left / 2, size.height - padding.bottom / 2 + bottomSpacing),
      );
    }

    // Left section (single line)
    if (padding.left > 0) {
      final leftX = padding.left / 2;
      //line: 10
      canvas.drawLine(
        Offset(leftX, size.height * 0.2 + dotRadius * 4),
        Offset(leftX, size.height * 0.4 - dotRadius * 4),
        secondaryLinePaint,
      );
      canvas.drawCircle(Offset(leftX, size.height * 0.2 + dotRadius * 4),
          dotRadius, secondaryDotPaint);
      canvas.drawCircle(Offset(leftX, size.height * 0.4 - dotRadius * 4),
          dotRadius, secondaryDotPaint);
      //line:9
      canvas.drawLine(
        Offset(leftX, size.height * 0.4 + dotRadius * 2),
        Offset(leftX, size.height - padding.bottom / 2),
        _createLinePaint(
          Offset(leftX, size.height * 0.4 + dotRadius * 2),
          Offset(leftX, size.height - padding.bottom / 2),
        ),
      );

      _drawDot(
        canvas,
        Offset(leftX, size.height * 0.4 + dotRadius * 2),
      );
    }

    // Right section (single line)
    if (padding.right > 0) {
      final rightX = size.width - padding.right / 2;
      // line : 5
      canvas.drawLine(
        Offset(rightX, size.height * 0.5 + dotRadius * 2),
        Offset(rightX, size.height * 0.6),
        secondaryLinePaint,
      );
    }
  }

  void _drawRoundedCorners(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color.fromRGBO(74, 198, 249, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth * 4;

    const double cornerRadius = 12.0; // Radius for rounded corners
    const double cornerLength = 20.0; // Length of each corner's line

    // Top-left corner
    final RRect topLeftRRect = RRect.fromLTRBAndCorners(
      padding.left,
      padding.top,
      padding.left + cornerLength,
      padding.top + cornerLength + 10.0,
      topLeft: const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(topLeftRRect, linePaint);

    // Top-right corner
    final RRect topRightRRect = RRect.fromLTRBAndCorners(
      size.width - padding.right - cornerLength,
      padding.top,
      size.width - padding.right,
      padding.top + cornerLength + 10.0,
      topRight: const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(topRightRRect, linePaint);

    // Bottom-left corner
    final RRect bottomLeftRRect = RRect.fromLTRBAndCorners(
      padding.left,
      size.height - padding.bottom - cornerLength - 10.0,
      padding.left + cornerLength,
      size.height - padding.bottom,
      bottomLeft: const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(bottomLeftRRect, linePaint);

    // Bottom-right corner
    final RRect bottomRightRRect = RRect.fromLTRBAndCorners(
      size.width - padding.right - cornerLength,
      size.height - padding.bottom - cornerLength - 10.0,
      size.width - padding.right,
      size.height - padding.bottom,
      bottomRight: const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(bottomRightRRect, linePaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();

    // Create outer rounded rectangle
    final outerRect = RRect.fromRectAndRadius(
        Offset.zero & size, Radius.zero // Adjust the radius as needed
        );

    // Create inner rounded rectangle
    final innerRect = RRect.fromLTRBAndCorners(
      padding.left,
      padding.top,
      size.width - padding.right,
      size.height - padding.bottom,
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );

    // Clip the canvas with the rounded path
    final outerPath = Path()..addRRect(outerRect);
    final innerPath = Path()..addRRect(innerRect);

    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        outerPath,
        innerPath,
      ),
    );

    // Fill the clipped area
    canvas.drawRect(Offset.zero & size, fillPaint);

    // Draw the corner lines and dots
    _drawCornerLines(canvas, size);
    _drawRoundedCorners(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is FramePainter) {
      return oldDelegate.color != color ||
          oldDelegate.padding != padding ||
          oldDelegate.lineColor != lineColor ||
          oldDelegate.lineWidth != lineWidth ||
          oldDelegate.dotRadius != dotRadius;
    }
    return true;
  }
}
