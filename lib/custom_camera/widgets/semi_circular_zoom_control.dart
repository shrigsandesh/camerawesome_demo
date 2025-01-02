import 'dart:math' as math;
import 'package:flutter/material.dart';

class SemiCircularZoomControl extends StatefulWidget {
  final double minZoom;
  final double maxZoom;
  final int divisions;
  final Function(double) onZoomChanged;
  final double initialZoom;

  const SemiCircularZoomControl({
    super.key,
    this.minZoom = 1.0,
    this.maxZoom = 5.0,
    this.divisions = 4,
    required this.onZoomChanged,
    this.initialZoom = 1.0,
  });

  @override
  State<SemiCircularZoomControl> createState() =>
      _SemiCircularZoomControlState();
}

class _SemiCircularZoomControlState extends State<SemiCircularZoomControl> {
  late double _currentZoom;
  final double _startAngle = -math.pi / 2;
  final double _endAngle = math.pi / 2;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
  }

  double _angleToZoom(double angle) {
    final normalizedAngle = (angle - _startAngle) / (_endAngle - _startAngle);
    return widget.minZoom + (widget.maxZoom - widget.minZoom) * normalizedAngle;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 300,
      child: GestureDetector(
        onPanUpdate: (details) {
          final box = context.findRenderObject() as RenderBox;
          final center = Offset(box.size.width / 2, box.size.height);
          final angle = math.atan2(details.localPosition.dx - center.dx,
              center.dy - details.localPosition.dy);

          if (angle >= _startAngle && angle <= _endAngle) {
            final newZoom = _angleToZoom(angle);
            setState(() {
              _currentZoom = newZoom;
            });
            widget.onZoomChanged(newZoom);
          }
        },
        child: CustomPaint(
          painter: _ZoomControlPainter(
            currentZoom: _currentZoom,
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            divisions: widget.divisions,
            startAngle: _startAngle,
            endAngle: _endAngle,
          ),
        ),
      ),
    );
  }
}

class _ZoomControlPainter extends CustomPainter {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final int divisions;
  final double startAngle;
  final double endAngle;

  _ZoomControlPainter({
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.divisions,
    required this.startAngle,
    required this.endAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.height - 20;

    // Draw background arc
    final bgPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle - startAngle,
      false,
      bgPaint,
    );

    // Draw active arc
    final activePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final currentAngle = startAngle +
        (endAngle - startAngle) *
            ((currentZoom - minZoom) / (maxZoom - minZoom));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentAngle - startAngle,
      false,
      activePaint,
    );

    // Draw ruler lines and labels
    final linePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw major divisions
    for (int i = 0; i <= divisions; i++) {
      final zoom = minZoom + (maxZoom - minZoom) * (i / divisions);
      final angle = startAngle + (endAngle - startAngle) * (i / divisions);

      // Draw major tick line
      final outerPoint = Offset(
        center.dx + (radius + 5) * math.sin(angle),
        center.dy - (radius + 5) * math.cos(angle),
      );
      final innerPoint = Offset(
        center.dx + (radius - 15) * math.sin(angle),
        center.dy - (radius - 15) * math.cos(angle),
      );

      canvas.drawLine(innerPoint, outerPoint, linePaint);

      // Draw label
      final labelOffset = Offset(
        center.dx + (radius + 25) * math.sin(angle),
        center.dy - (radius + 25) * math.cos(angle),
      );

      textPainter.text = TextSpan(
        text: '${zoom.toStringAsFixed(1)}X',
        style: TextStyle(
          color: zoom <= currentZoom ? Colors.blue : Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        labelOffset.translate(-textPainter.width / 2, -textPainter.height / 2),
      );
    }

    // Draw minor divisions
    final minorDivisions = divisions * 5; // 5 minor ticks between major ticks
    final minorLinePaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= minorDivisions; i++) {
      if (i % 5 != 0) {
        // Skip positions where major ticks are drawn
        final angle =
            startAngle + (endAngle - startAngle) * (i / minorDivisions);

        final outerPoint = Offset(
          center.dx + (radius + 2) * math.sin(angle),
          center.dy - (radius + 2) * math.cos(angle),
        );
        final innerPoint = Offset(
          center.dx + (radius - 8) * math.sin(angle),
          center.dy - (radius - 8) * math.cos(angle),
        );

        canvas.drawLine(innerPoint, outerPoint, minorLinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
