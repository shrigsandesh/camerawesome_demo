import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/padding_painter.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/camera_action_widget.dart';
import 'package:camerawesome_demo/custom_camera/widgets/info_popup.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CameraContent extends StatelessWidget {
  const CameraContent({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CameraAwesomeBuilder.custom(
        builder: (state, preview) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //camera section
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    //outer painted region
                    CustomPaint(
                      painter: PaddingPainter(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 40.0),
                          color: Colors.white.withOpacity(.74), //paint color
                          borderRadius: 36.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 40.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(36.0),
                          border: Border.all(width: 2.0, color: Colors.white),
                        ),
                      ),
                    ),
                    //yellow boundary
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 30.0 + 50.0, vertical: 40.0 + 89.0),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.yellow, width: 2.0),
                            borderRadius: BorderRadius.circular(36.0)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 0.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Make sure the PROOF BALL is inside yellow boundary ",
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                                style: context.bodyMedium.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const InfoPopup(),
                                  );
                                },
                                child: SvgPicture.asset(
                                  'assets/question.svg',
                                  height: 18.0,
                                  width: 18.0,
                                )),
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
              //camera control section at bottom
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
    });
  }
}
