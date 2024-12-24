import 'package:flutter/material.dart';

class ScrollableBarScale extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final ValueChanged<double>? onChanged;
  final double barWidth;
  final double spacing;

  const ScrollableBarScale({
    super.key,
    this.min = 1.0,
    this.max = 10.0,
    this.initialValue = 1.0,
    this.onChanged,
    this.barWidth = 4,
    this.spacing = 15,
  });

  @override
  State<ScrollableBarScale> createState() => _ScrollableBarScaleState();
}

class _ScrollableBarScaleState extends State<ScrollableBarScale> {
  late ScrollController _scrollController;
  late double _currentValue;
  late int totalBars;
  final int barsPerUnit = 5;
  bool _isInitialJump = true;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    totalBars = ((widget.max - widget.min) * barsPerUnit).round();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _calculateValue(double offset, double viewportWidth) {
    final double effectiveOffset = offset - (viewportWidth / 2);
    final double valueOffset =
        effectiveOffset / ((widget.barWidth + widget.spacing) * barsPerUnit);
    return (widget.min + valueOffset).clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final double sidePadding = viewportWidth / 2 - widget.spacing / 2;

        // Only set initial position once
        if (_isInitialJump) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final double initialScrollOffset = ((_currentValue - widget.min) *
                  (widget.barWidth + widget.spacing) *
                  barsPerUnit);
              _scrollController.jumpTo(initialScrollOffset);
              _isInitialJump = false;
            }
          });
        }

        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.5),
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                final newValue = _calculateValue(
                  scrollNotification.metrics.pixels,
                  viewportWidth,
                );

                if (newValue != _currentValue) {
                  setState(() {
                    _currentValue = newValue;
                  });
                  widget.onChanged?.call(_currentValue);
                }
              }
              return true;
            },
            child: Stack(
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white,
                        Colors.white,
                        Colors.white.withOpacity(0),
                      ],
                      stops: const [0.0, 0.1, 0.9, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        SizedBox(width: sidePadding),
                        ...List.generate(
                          totalBars,
                          (index) {
                            bool isWholeNumber = index % barsPerUnit == 0;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: widget.barWidth,
                                  height: isWholeNumber ? 30 : 15,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: widget.spacing / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(width: sidePadding),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 2,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
