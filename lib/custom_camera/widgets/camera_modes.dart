import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class CustomCameraModes extends StatefulWidget {
  final OnChangeCameraRequest onChangeCameraRequest;

  final List<CaptureMode> availableModes;
  final CaptureMode? initialMode;
  final VoidCallback on3DVideoTapped;

  const CustomCameraModes({
    super.key,
    required this.onChangeCameraRequest,
    required this.availableModes,
    required this.initialMode,
    required this.on3DVideoTapped,
  });

  @override
  State<CustomCameraModes> createState() => _CustomCameraModesState();
}

class _CustomCameraModesState extends State<CustomCameraModes> {
  late PageController _pageController;

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialMode != null
        ? widget.availableModes.indexOf(widget.initialMode!)
        : 0;
    _pageController =
        PageController(viewportFraction: 0.25, initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableModes.length <= 1) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: _pageController,
              onPageChanged: (index) {
                if (index <= 1) {
                  final cameraMode = widget.availableModes[index];
                  widget.onChangeCameraRequest(cameraMode);
                } else {
                  widget.on3DVideoTapped();
                }
                setState(() {
                  _index = index;
                });
              },
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _index == 0 ? 1 : 0.2,
                  child: AwesomeBouncingWidget(
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Photo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.onChangeCameraRequest(CaptureMode.photo);
                      _pageController.animateToPage(
                        0,
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 200),
                      );
                    },
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _index == 1 ? 1 : 0.2,
                  child: AwesomeBouncingWidget(
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.onChangeCameraRequest(CaptureMode.photo);
                      _pageController.animateToPage(
                        1,
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 200),
                      );
                    },
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _index == 2 ? 1 : 0.2,
                  child: AwesomeBouncingWidget(
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '3D Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      _pageController.animateToPage(
                        2,
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 200),
                      );
                      widget.on3DVideoTapped();
                    },
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
