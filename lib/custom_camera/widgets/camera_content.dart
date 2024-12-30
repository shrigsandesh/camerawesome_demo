import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/padding_painter.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/camera_action_widget.dart';
import 'package:camerawesome_demo/custom_camera/widgets/info_popup.dart';
import 'package:camerawesome_demo/custom_camera/widgets/orientation_wrapper.dart';
import 'package:camerawesome_demo/custom_camera/widgets/responsive_text_box.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CameraContent extends StatelessWidget {
  const CameraContent({super.key, required this.pageController});

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return OrientationWrapperWidget(builder: (context, orientation) {
      final isPortrait = orientation == Orientation.portrait;
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
                        padding: CameraConstants.outerPadding,
                        color: Colors.white.withOpacity(.74), //paint color
                        borderRadius: CameraConstants.borderRadius,
                      ),
                      child: Container(
                        margin: CameraConstants.outerPadding,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                              CameraConstants.borderRadius),
                          border: Border.all(
                            width: 2.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    //yellow boundary
                    Center(
                      child: Container(
                        margin: CameraConstants.getInnerPadding(),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.yellow, width: 2.0),
                          borderRadius: BorderRadius.circular(
                            CameraConstants.borderRadius,
                          ),
                        ),
                      ),
                    ),

                    //boundary info
                    isPortrait
                        ? const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 0.0),
                              child: _BoundaryInfoBox(Orientation.portrait),
                            ),
                          )
                        : const Align(
                            alignment: Alignment.topRight,
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: _BoundaryInfoBox(Orientation.landscape),
                              ),
                            ),
                          ),
                    //
                    ResponsiveTextBox(
                      text: 'Proof Ball Boundary',
                      orientation: orientation,
                      landscapeAlignment: Alignment.topRight,
                      //in landscape mode:
                      //since widget is rotated:
                      //*left padding=> original top padding of portrait mode,
                      //*top padding=> original right padding of portrait mode
                      landscapePadding: const EdgeInsets.fromLTRB(
                          CameraConstants.outerVerticalSpacing +
                              CameraConstants.innerVerticalSpacing +
                              15.0, //left padding*
                          CameraConstants.outerHorizontalSpacing +
                              CameraConstants.innerHorizontalSpacing +
                              10.0, //top padding*
                          0,
                          0.0),
                      //
                      portraitPadding: const EdgeInsets.fromLTRB(
                          CameraConstants.outerHorizontalSpacing +
                              CameraConstants.innerHorizontalSpacing +
                              20.0,
                          0,
                          0,
                          CameraConstants.outerVerticalSpacing +
                              CameraConstants.innerVerticalSpacing +
                              3.0),
                    ),
                    ResponsiveTextBox(
                      text: 'Fish boundary',
                      orientation: orientation,
                      //in landscape mode:
                      //default  alignment is : Alignment.topLeft,
                      //since widget is rotated:
                      //*left padding=> original top padding of portrait mode,
                      //*bottom padding=> original left padding of portrait mode
                      landscapePadding: const EdgeInsets.fromLTRB(
                        CameraConstants.outerVerticalSpacing + 20.0, //*left
                        0,
                        0,
                        CameraConstants.outerHorizontalSpacing + 5.0, //*bottom
                      ),
                      portraitPadding: const EdgeInsets.fromLTRB(
                        CameraConstants.outerVerticalSpacing + 10.0,
                        0,
                        0,
                        CameraConstants.outerHorizontalSpacing + 15.0,
                      ),
                    ),
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

class _BoundaryInfoBox extends StatelessWidget {
  const _BoundaryInfoBox(this.orientation);
  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Make sure the PROOF BALL is inside yellow boundary ",
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: context.bodyMedium
              .copyWith(color: Colors.black, fontWeight: FontWeight.w500),
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
    );
  }
}
