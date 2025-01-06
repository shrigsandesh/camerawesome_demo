import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

final PageStorageBucket _storageBucket = PageStorageBucket();

class ZoomBar extends StatefulWidget {
  const ZoomBar({
    super.key,
    required this.onZoomChanged,
    required this.cameraState,
  });

  final Function(double val) onZoomChanged;
  final CameraState? cameraState;

  @override
  State<ZoomBar> createState() => _ZoomBarState();
}

class _ZoomBarState extends State<ZoomBar> {
  bool _isOpen = false;
  double? _zoomLevel = 1.0;
  final GlobalKey<_ZoomScaleBarState> _zoomScaleBarKey =
      GlobalKey<_ZoomScaleBarState>();

  void showHideZoomBar() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _isOpen = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _storageBucket,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              showHideZoomBar();
            },
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: Text(
                "${_zoomLevel?.toStringAsFixed(1)}x",
                style: TextStyle(color: Colors.white.withOpacity(.5)),
              ),
            ),
          ),
          ColoredBox(
            color: Colors.black.withOpacity(.5),
            child: StreamBuilder<double>(
              stream: widget.cameraState?.sensorConfig.zoom$,
              builder: (context, snapshot) {
                if (snapshot.data == null || !_isOpen) {
                  return const SizedBox.shrink();
                }
                return AnimatedOpacity(
                  duration: const Duration(seconds: 1),
                  opacity: _isOpen ? 1.0 : 0.0,
                  child: ZoomScaleBar(
                    key: _zoomScaleBarKey,
                    initialZoom: _zoomLevel ?? 1.0,
                    onZoomChanged: (val) {
                      setState(() {
                        _zoomLevel = val;
                      });
                      widget.cameraState?.sensorConfig
                          .setZoom(normalizeZoom(val));
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
  final int _totalTicks = 24;
  final double _tickSpacing = 12.0;
  double _currentZoom = 1.0;

  static const String _scrollPositionKey = 'zoom_scroll_position';

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storedPosition = PageStorage.of(context).readState(
        context,
        identifier: _scrollPositionKey,
      );
      if (storedPosition != null && _scrollController.hasClients) {
        _scrollController.jumpTo(storedPosition as double);
      } else {
        final initialPosition =
            _calculateScrollPositionForZoom(widget.initialZoom);
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(initialPosition);
        }
      }
    });
  }

  @override
  void dispose() {
    if (_scrollController.hasClients) {
      PageStorage.of(context).writeState(
        context,
        _scrollController.offset,
        identifier: _scrollPositionKey,
      );
    }
    _scrollController.dispose();
    super.dispose();
  }

  double _calculateScrollPositionForZoom(double zoom) {
    final maxScroll = _totalTicks * _tickSpacing;
    final percentage = _reverseMapZoomToPercentage(zoom);
    return percentage * maxScroll;
  }

  void _onScroll() {
    final scrollPosition = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    _currentZoom = _mapScrollToZoom(scrollPosition, maxScroll);
    widget.onZoomChanged(_currentZoom);

    PageStorage.of(context).writeState(
      context,
      scrollPosition,
      identifier: _scrollPositionKey,
    );
  }

  void scrollToZoom(double targetZoom) {
    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _performScrollToZoom(targetZoom);
        }
      });
    } else {
      _performScrollToZoom(targetZoom);
    }
  }

  void _performScrollToZoom(double targetZoom) {
    final scrollPosition = _calculateScrollPositionForZoom(targetZoom);
    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  double _reverseMapZoomToPercentage(double zoom) {
    if (zoom <= 2) {
      return (zoom - 1) * 0.25;
    } else if (zoom <= 4) {
      return 0.25 + ((zoom - 2) / 2) * 0.25;
    } else {
      return 0.5 + ((zoom - 4) / 6) * 0.5;
    }
  }

  double _mapScrollToZoom(double scrollPosition, double maxScroll) {
    final percentage = scrollPosition / maxScroll;
    if (percentage <= 0.25) {
      return 1 + (percentage / 0.25);
    } else if (percentage <= 0.5) {
      return 2 + ((percentage - 0.25) / 0.25) * 2;
    } else {
      return 4 + ((percentage - 0.5) / 0.5) * 6;
    }
  }

  List<Widget> _buildTicks() {
    final ticks = <Widget>[];
    final maxScroll = _totalTicks * _tickSpacing;

    for (var i = 0; i <= _totalTicks; i++) {
      final position = i * _tickSpacing;
      double zoomAtTick = _mapScrollToZoom(position, maxScroll);

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
      alignment: Alignment.topCenter,
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
            height: 40,
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
