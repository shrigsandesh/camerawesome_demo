import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/frame_painter.dart';

import 'package:camerawesome_demo/custom_camera/widgets/orientation_wrapper.dart';
import 'package:flutter/material.dart';

class CameraContent extends StatefulWidget {
  const CameraContent({
    super.key,
    this.showInstruction = true,
  });

  final bool showInstruction;

  @override
  State<CameraContent> createState() => _CameraContentState();
}

class _CameraContentState extends State<CameraContent> {
  @override
  Widget build(BuildContext context) {
    return OrientationWrapperWidget(builder: (context, orientation) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //camera section
          Expanded(
            flex: 15,
            child: !widget.showInstruction
                ? const SizedBox()
                : Stack(
                    children: [
                      //frame
                      CustomPaint(
                        painter: FramePainter(
                          padding: CameraConstants.outerPadding,
                          color:
                              const Color.fromRGBO(0, 5, 34, 0.8), //paint color
                        ),
                        child: Container(
                          margin: CameraConstants.outerPadding,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      );
    });
  }
}
