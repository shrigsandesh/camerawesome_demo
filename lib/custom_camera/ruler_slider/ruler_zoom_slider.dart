import 'package:camerawesome_demo/custom_camera/ruler_slider/ruler_slider.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:camerawesome_demo/extensions/double_extensions.dart';
import 'package:flutter/material.dart';

class RulerZoomSlider extends StatefulWidget {
  const RulerZoomSlider({super.key, required this.onChanged});

  final void Function(double value) onChanged;

  @override
  State<RulerZoomSlider> createState() => _RulerZoomSliderState();
}

class _RulerZoomSliderState extends State<RulerZoomSlider> {
  static final GlobalKey<RulerSliderState> rulerKey =
      GlobalKey<RulerSliderState>();

  bool _isOpen = false;
  double? _currentZoom;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: !_isOpen
          ? Padding(
              padding: const EdgeInsets.all(4.0),
              child: _ZoomBtn(
                  title: _currentZoom != null
                      ? "${_currentZoom?.toFormattedString()}x"
                      : "1.0x",
                  onTap: () {
                    setState(() {
                      _isOpen = !_isOpen;
                    });
                  }),
            )
          : TapRegion(
              onTapOutside: (event) {
                _isOpen = false;
              },
              child: AnimatedOpacity(
                opacity: _isOpen ? 1.0 : 0.2,
                duration: const Duration(seconds: 1),
                child: ColoredBox(
                  color: Colors.black.withOpacity(.5),
                  child: Column(
                    children: [
                      RulerSlider(
                        key: rulerKey,
                        minValue: 2.0,
                        maxValue: 20.0, //20 bars for 10x zoom
                        initialValue: _currentZoom != null
                            ? _currentZoom! * 2
                            : 0.0, // multiply by 2 becacuse there are 20 bars instead of 10
                        rulerHeight: 80.0,
                        selectedBarColor: Colors.yellow,
                        unselectedBarColor: Colors.grey,
                        tickSpacing: 10.0,
                        valueTextStyle:
                            const TextStyle(color: Colors.yellow, fontSize: 18),
                        onChanged: (val) {
                          widget.onChanged(val);
                          setState(() {
                            _currentZoom = val / 2; //since total bars are 20
                          });
                        },
                        showFixedBar: true,
                        fixedBarColor: Colors.yellow,
                        fixedBarWidth: 3.0,
                        fixedBarHeight: 40.0,
                        showFixedLabel: true,
                        fixedLabelColor: Colors.white,
                        scrollSensitivity: 1.0,
                        enableSnapping: false,
                        majorTickInterval: 4,
                        labelInterval: 10,
                        showBottomLabels: false,
                        labelTextStyle:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        majorTickHeight: 15.0,
                        minorTickHeight: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ZoomBtn(
                            title: '1x',
                            onTap: () {
                              rulerKey.currentState?.scrollToValue(0.0);
                            },
                          ),
                          _ZoomBtn(
                            title: '2x',
                            onTap: () {
                              rulerKey.currentState?.scrollToValue(4.0); //2*2
                            },
                          ),
                          _ZoomBtn(
                            title: '4x',
                            onTap: () {
                              rulerKey.currentState?.scrollToValue(8.0); //4*2
                            },
                          ),
                          _ZoomBtn(
                            title: '10x',
                            onTap: () {
                              rulerKey.currentState?.scrollToValue(20.0); //10*2
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      )
                    ],
                  ),
                ),
              ),
            ),
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
        width: 28.0,
        height: 28.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(.8), shape: BoxShape.circle),
        child: Center(
          child: Text(
            title,
            style: context.bodyMedium.copyWith(fontSize: 12.0),
          ),
        ),
      ),
    );
  }
}
