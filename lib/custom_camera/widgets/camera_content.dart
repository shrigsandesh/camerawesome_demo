import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/padding_painter.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/camera_action_widget.dart';
import 'package:camerawesome_demo/custom_camera/widgets/info_popup.dart';
import 'package:flutter/material.dart';

class CameraContent extends StatelessWidget {
  const CameraContent({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.custom(
      builder: (state, preview) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: PaddingPainter(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 40.0),
                        color: Colors.blue.shade300.withOpacity(.7),
                        borderRadius: 36.0),
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 40.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(36.0),
                            border: Border.all(width: 2.0, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30.0 + 50.0, vertical: 40.0 + 89.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: 2.0),
                          borderRadius: BorderRadius.circular(36.0)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(39.0, 10.0, 0.0, 10.0),
                      child: Row(
                        children: [
                          const Text(
                            "Make sure the PROOF BALL is inside yellow boundary ",
                            overflow: TextOverflow.visible,
                            style: TextStyle(fontSize: 12),
                          ),
                          InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const InfoPopup(),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 2, color: Colors.blue.shade300)),
                                child: Icon(
                                  Icons.question_mark_outlined,
                                  color: Colors.blue.shade300,
                                  size: 12,
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 42,
                    left: 65,
                    child: Text(
                      'Fish Boundary',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Positioned(
                    bottom: 130,
                    left: 123,
                    child: Text(
                      'Proof Ball Boundary',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: CameraActionWidget(
                cameraState: state,
                pageController: pageController,
              ),
            ),
          ],
        );
      },
      onMediaCaptureEvent: (mediaCapture) {},
      saveConfig: SaveConfig.photoAndVideo(),
    );
  }
}
