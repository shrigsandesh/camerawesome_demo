import 'package:flutter/widgets.dart';

class BoundaryBoxBorder extends StatelessWidget {
  final Rect rect;
  final Color borderColor;
  final double borderWidth;

  const BoundaryBoxBorder({
    super.key,
    required this.rect,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
        rect: rect,
        child: CustomPaint(
          foregroundPainter: FishBoundaryBoxScannerBorderPainter(
            borderColor,
            borderWidth,
          ),
        ));
  }
}

// Modified to use topLeft and bottomRight for rectangle
class FishBoundaryBoxScannerBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;

  FishBoundaryBoxScannerBorderPainter(this.borderColor, this.borderWidth);

  @override
  void paint(Canvas canvas, Size size) {
    const width = 2.0;
    const radius = 2.5;
    const tRadius = 3 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    const clippingRect0 = Rect.fromLTWH(
      0,
      0, // Adjust these values for desired gap
      2.7 * tRadius,
      tRadius, // Increase height for top gap
    );

    final clippingRect1 = Rect.fromLTWH(
      size.width - 2.7 * tRadius, // Adjusted width for longer top left side
      0,
      2.7 * tRadius,
      tRadius,
    );
    final clippingRect2 = Rect.fromLTWH(
      0,
      size.height - tRadius,
      tRadius * 2.7,
      tRadius,
    );
    final clippingRect3 = Rect.fromLTWH(
      size.width - 2.7 * tRadius,
      size.height - tRadius,
      tRadius * 2.7,
      tRadius,
    );
    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
