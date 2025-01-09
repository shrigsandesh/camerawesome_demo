import 'package:camerawesome_demo/custom_camera/ruler_slider/ruler_slider.dart';
import 'package:camerawesome_demo/custom_camera/ruler_slider/ruler_zoom_slider_config.dart';
import 'package:camerawesome_demo/custom_camera/ruler_slider/zoom_button.dart';
import 'package:camerawesome_demo/extensions/double_extensions.dart';
import 'package:flutter/material.dart';

class RulerZoomSlider extends StatefulWidget {
  final void Function(double value) onChanged;
  final RulerZoomSliderConfig config;
  final double? initialZoom;

  const RulerZoomSlider({
    super.key,
    required this.onChanged,
    this.config = const RulerZoomSliderConfig(),
    this.initialZoom,
  });

  @override
  State<RulerZoomSlider> createState() => _RulerZoomSliderState();
}

class _RulerZoomSliderState extends State<RulerZoomSlider> {
  static final GlobalKey<RulerSliderState> _rulerKey =
      GlobalKey<RulerSliderState>();

  bool _isOpen = false;
  double? _currentZoom;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
  }

  void _handleZoomChange(double value) {
    widget.onChanged(value);
    setState(() => _currentZoom = value);
  }

  void _toggleSlider() {
    setState(() => _isOpen = !_isOpen);
  }

  double _calculateScrollValue(double zoomLevel) {
    if (zoomLevel == widget.config.minValue) return 0.0;

    if (widget.config.maxDisplayValue != null &&
        widget.config.maxDisplayValue != widget.config.maxZoomBars) {
      return widget.config.maxZoomBars /
          widget.config.maxDisplayValue! *
          zoomLevel;
    }

    return zoomLevel;
  }

  Widget _buildZoomButton(double zoomLevel) {
    return ZoomButton(
      title: '${zoomLevel.toFormattedString()}x',
      onTap: () => _rulerKey.currentState?.scrollToValue(
        _calculateScrollValue(zoomLevel),
      ),
    );
  }

  String _formatZoomTitle(double? currentZoom) {
    // Handle null or small zoom values
    if (currentZoom == null || currentZoom <= 1.0) {
      return "1.0x";
    }
    // Calculate adjusted zoom value if maxDisplayValue is set
    if (widget.config.maxDisplayValue != null &&
        widget.config.maxDisplayValue != widget.config.maxZoomBars) {
      final adjustedZoom = currentZoom *
          widget.config.maxDisplayValue! /
          widget.config.maxZoomBars;
      return "${adjustedZoom.toFormattedString()}x";
    }

    // Default formatting for normal zoom values
    return "${currentZoom.toFormattedString()}x";
  }

  Widget _buildCollapsedView() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ZoomButton(
        title: _formatZoomTitle(_currentZoom),
        onTap: _toggleSlider,
      ),
    );
  }

  Widget _buildRulerSlider() {
    return RulerSlider(
      key: _rulerKey,
      minValue: widget.config.minValue ?? 0.0,
      maxValue: widget.config.maxZoomBars,
      initialValue: _currentZoom ?? 0.0,
      rulerHeight: widget.config.rulerHeight,
      selectedBarColor: widget.config.selectedBarColor,
      unselectedBarColor: widget.config.unselectedBarColor,
      tickSpacing: widget.config.tickSpacing,
      valueTextStyle: widget.config.valueTextStyle,
      onChanged: _handleZoomChange,
      showFixedBar: true,
      fixedBarColor: widget.config.fixedBarColor,
      fixedBarWidth: widget.config.fixedBarWidth,
      fixedBarHeight: widget.config.fixedBarHeight,
      showFixedLabel: true,
      fixedLabelColor: widget.config.fixedLabelColor,
      scrollSensitivity: widget.config.scrollSensitivity,
      enableSnapping: false,
      majorTickInterval: widget.config.majorTickInterval,
      labelInterval: widget.config.labelInterval,
      showBottomLabels: false,
      labelTextStyle: widget.config.labelTextStyle,
      majorTickHeight: widget.config.majorTickHeight,
      minorTickHeight: widget.config.minorTickHeight,
      displayValueBuilder: widget.config.displayValueBuilder,
      disValToZoomRatio: widget.config.maxDisplayValue != null
          ? widget.config.maxDisplayValue! / widget.config.maxZoomBars
          : 1.0,
    );
  }

  Widget _buildZoomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widget.config.zoomLevels.map(_buildZoomButton).toList(),
    );
  }

  Widget _buildExpandedView() {
    return TapRegion(
      onTapOutside: (_) => setState(() => _isOpen = false),
      child: AnimatedOpacity(
        opacity: _isOpen ? 1.0 : 0.2,
        duration: RulerZoomConstants.animationDuration,
        child: ColoredBox(
          color: Colors.black.withOpacity(.5),
          child: Column(
            children: [
              _buildRulerSlider(),
              _buildZoomButtons(),
              const SizedBox(height: 5.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: RulerZoomConstants.animationDuration,
      child: _isOpen ? _buildExpandedView() : _buildCollapsedView(),
    );
  }
}
