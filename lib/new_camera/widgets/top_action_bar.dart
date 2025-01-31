import 'package:camera/camera.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:camerawesome_demo/new_camera/widgets/flash_mode_toggle_button.dart';
import 'package:flutter/material.dart';

class TopActionBar extends StatelessWidget {
  const TopActionBar({
    super.key,
    this.recordingTime,
    required this.selectedMode,
    required this.controller,
  });
  final String? recordingTime;
  final FishtechyCameraMode selectedMode;
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlashModeToggleButton(controller: controller),
          if (recordingTime != null)
            AnimatedOpacity(
              opacity: (recordingTime != '00:00' &&
                      controller.value.isRecordingVideo &&
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
