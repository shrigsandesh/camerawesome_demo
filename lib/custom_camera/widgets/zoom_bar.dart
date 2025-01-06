import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class ZoomBar extends StatefulWidget {
  const ZoomBar(
      {super.key, required this.onZoomChanged, required this.cameraState});

  final Function(double val) onZoomChanged;
  final CameraState? cameraState;

  @override
  State<ZoomBar> createState() => _ZoomBarState();
}

class _ZoomBarState extends State<ZoomBar> {
  bool _showZoombar = false;
  void showHideZoomBar() {
    setState(() {
      _showZoombar = !_showZoombar;
    });
    if (_showZoombar) {
      Timer(const Duration(seconds: 5), () {
        setState(() {
          _showZoombar = false; // Hide the widget
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ZoomBtn(
                title: '0.5x',
                onTap: () {
                  showHideZoomBar();
                },
              ),
              _ZoomBtn(
                title: '1.0x',
                onTap: () {
                  showHideZoomBar();
                },
              ),
              _ZoomBtn(
                title: '1.5x',
                onTap: () {
                  showHideZoomBar();
                },
              ),
            ],
          ),
        ),
        if (_showZoombar)
          AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _showZoombar ? 1.0 : 0.0,
            child: StreamBuilder<double>(
                stream: widget.cameraState?.sensorConfig.zoom$,
                builder: (_, snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  return ZoomScaleBar(
                    onZoomChanged: (val) {
                      widget.cameraState?.sensorConfig
                          .setZoom(normalizeZoom(val));
                    },
                  );
                }),
          )
      ],
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  const _ZoomBtn({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.black.withOpacity(.5)),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ZoomScaleBar extends StatefulWidget {
  final Function(double) onZoomChanged;
  final double initialZoom;

  const ZoomScaleBar({
    super.key,
    required this.onZoomChanged,
    this.initialZoom = 1.0,
  });

  @override
  State<ZoomScaleBar> createState() => _ZoomScaleBarState();
}

class _ZoomScaleBarState extends State<ZoomScaleBar> {
  late ScrollController _scrollController;
  final List<double> _majorZoomLevels = [1, 2, 4, 10];

  // Adjusted to make last tick align with max zoom
  final int _totalTicks = 24;
  final double _tickSpacing = 12.0;

  double _currentZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollPosition = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    _currentZoom = _mapScrollToZoom(scrollPosition, maxScroll);
    widget.onZoomChanged(_currentZoom);
  }

  double _mapScrollToZoom(double scrollPosition, double maxScroll) {
    final percentage = scrollPosition / maxScroll;
    if (percentage <= 0.25) {
      return 1 + (percentage / 0.25); // 1 to 2
    } else if (percentage <= 0.5) {
      return 2 + ((percentage - 0.25) / 0.25) * 2; // 2 to 4
    } else {
      return 4 + ((percentage - 0.5) / 0.5) * 6; // 4 to 10
    }
  }

  List<Widget> _buildTicks() {
    final ticks = <Widget>[];
    final maxScroll = _totalTicks * _tickSpacing;

    for (var i = 0; i <= _totalTicks; i++) {
      final position = i * _tickSpacing;
      double zoomAtTick = _mapScrollToZoom(position, maxScroll);

      // Make the last tick always a major tick
      final isMajorTick = i == _totalTicks - 1 ||
          _majorZoomLevels.any((zoom) => (zoomAtTick - zoom).abs() < 0.05);

      ticks.add(
        Positioned(
          left: position,
          child: Container(
            width: 2,
            height: isMajorTick ? 20 : 15,
            color: isMajorTick ? Colors.white : Colors.white.withOpacity(0.3),
          ),
        ),
      );
    }
    return ticks;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                ),
                SizedBox(
                  height: 50,
                  width: _totalTicks * _tickSpacing,
                  child: Stack(
                    children: _buildTicks(),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 2,
            height: 30,
            color: Colors.yellow,
          ),
        ),
      ],
    );
  }
}

double normalizeZoom(double input) {
  return (input - 1.0) / (10.0 - 1.0);
}
