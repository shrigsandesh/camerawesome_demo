import 'dart:math';
import 'package:flutter/material.dart';

class CameraZoomControl extends StatefulWidget {
  final Function(double) onZoomChanged;
  final double initialZoom;

  const CameraZoomControl({
    super.key,
    required this.onZoomChanged,
    this.initialZoom = 1.0,
  });

  @override
  State<CameraZoomControl> createState() => _CameraZoomControlState();
}

class _CameraZoomControlState extends State<CameraZoomControl> {
  late double _currentZoom;
  late ScrollController _scrollController;
  final double _barSpacing = 10.0; // Space between vertical bars
  final int _totalBars = 50; // Total number of bars in the scale

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
    _scrollController = ScrollController(
      initialScrollOffset: _getOffsetFromZoom(_currentZoom),
    );
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _getZoomFromOffset(double offset) {
    // Convert scroll offset to zoom value (logarithmic scale)
    final maxOffset = _barSpacing * _totalBars;
    final position = (offset / maxOffset).clamp(0.0, 1.0);
    final logMin = log(0.5);
    final logMax = log(10);
    final logZoom = (position * (logMax - logMin)) + logMin;
    return exp(logZoom);
  }

  double _getOffsetFromZoom(double zoom) {
    // Convert zoom value to scroll offset
    final maxOffset = _barSpacing * _totalBars;
    final logMin = log(0.5);
    final logMax = log(10);
    final position = (log(zoom) - logMin) / (logMax - logMin);
    return position * maxOffset;
  }

  void _handleScroll() {
    final newZoom = _getZoomFromOffset(_scrollController.offset);
    if (newZoom != _currentZoom) {
      setState(() {
        _currentZoom = newZoom;
      });
      widget.onZoomChanged(newZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          // Zoom level display
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: Container(
          //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          //       decoration: BoxDecoration(
          //         color: Colors.black54,
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       child: Text(
          //         _getZoomDisplay(_currentZoom),
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     ),
          //   ),
          // ),

          // Scrollable scale with center indicator
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            height: 60,
            child: Stack(
              children: [
                // Scrollable scale
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: _barSpacing * _totalBars,
                    height: 60,
                    child: CustomPaint(
                      painter: ZoomScalePainter(
                        barSpacing: _barSpacing,
                        totalBars: _totalBars,
                      ),
                    ),
                  ),
                ),
                // Center indicator
                Center(
                  child: Container(
                    width: 3,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick zoom buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuickZoomButton(
                      label: '.5',
                      isSelected: (_currentZoom - 0.5).abs() < 0.1,
                      onTap: () {
                        _scrollController.animateTo(
                          _getOffsetFromZoom(0.5),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                    _QuickZoomButton(
                      label: '1×',
                      isSelected: (_currentZoom - 1.0).abs() < 0.1,
                      onTap: () {
                        _scrollController.animateTo(
                          _getOffsetFromZoom(1.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                    _QuickZoomButton(
                      label: '2',
                      isSelected: (_currentZoom - 2.0).abs() < 0.1,
                      onTap: () {
                        _scrollController.animateTo(
                          _getOffsetFromZoom(2.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ZoomScalePainter extends CustomPainter {
  final double barSpacing;
  final int totalBars;

  ZoomScalePainter({
    required this.barSpacing,
    required this.totalBars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2;

    for (int i = 0; i < totalBars; i++) {
      final x = i * barSpacing;
      final isMainBar = i % 5 == 0;
      final barHeight = isMainBar ? 24.0 : 16.0;

      canvas.drawLine(
        Offset(x, size.height / 2 - barHeight / 2),
        Offset(x, size.height / 2 + barHeight / 2),
        paint,
      );

      // Draw zoom values at main bars
      if (isMainBar) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: _getScaleText(i),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - textPainter.height),
        );
      }
    }
  }

  String _getScaleText(int index) {
    final position = index / totalBars;
    final logMin = log(0.5);
    final logMax = log(10);
    final logZoom = (position * (logMax - logMin)) + logMin;
    final zoom = exp(logZoom);
    return zoom.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(ZoomScalePainter oldDelegate) {
    return barSpacing != oldDelegate.barSpacing ||
        totalBars != oldDelegate.totalBars;
  }
}

class _QuickZoomButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickZoomButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
