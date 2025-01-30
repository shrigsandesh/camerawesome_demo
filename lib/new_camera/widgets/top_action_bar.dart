import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class TopActionBar extends StatelessWidget {
  const TopActionBar(
      {super.key,
      this.recordingTime,
      required this.isVideoRecording,
      required this.selectedMode});
  final String? recordingTime;
  final bool isVideoRecording;
  final FishtechyCameraMode selectedMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.flash_auto,
              color: Colors.white,
            ),
          ),
          if (recordingTime != null)
            AnimatedOpacity(
              opacity: (recordingTime != '00:00' &&
                      isVideoRecording &&
                      selectedMode == FishtechyCameraMode.video)
                  ? 1.0
                  : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    recordingTime!,
                    style: context.bodyMedium.copyWith(),
                  ),
                ),
              ),
            ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
