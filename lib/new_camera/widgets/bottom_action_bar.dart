import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/photo_capture_button.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/prrofball_dropdown.dart';
import 'package:camerawesome_demo/custom_camera/widgets/camera_actions/record_button.dart';
import 'package:camerawesome_demo/new_camera/widgets/bouncing_widget.dart';
import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.modePgController,
    required this.availableModes,
    required this.selectedMode,
    required this.onSelectionModeChanged,
    required this.onModeTapped,
    required this.onVideoRecording,
    required this.onVideoStopped,
  });

  final PageController modePgController;
  final List<FishtechyCameraMode> availableModes;
  final FishtechyCameraMode selectedMode;
  final void Function(int index) onSelectionModeChanged;
  final void Function(FishtechyCameraMode tab) onModeTapped;
  final void Function(String? timer) onVideoRecording;
  final VoidCallback onVideoStopped;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: modePgController,
                    onPageChanged: onSelectionModeChanged,
                    children: availableModes
                        .map(
                          (tab) => Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: tab.name == selectedMode.name ? 1 : 0.2,
                              child: BouncingWidget(
                                duration: const Duration(milliseconds: 300),
                                onTap: () => onModeTapped(tab),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      tab.name == 'threeD'
                                          ? "3D Video"
                                          : capitalizeFirstLetter(tab.name),
                                      style: const TextStyle(
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
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.square(
                  dimension: 46.0,
                ),
                if (selectedMode == FishtechyCameraMode.threeD) ...[
                  RecrodButton(
                    onVideoRecording: (time) {},
                    onRecordStart: () {
                      //onstart
                    },
                    onRecordStopped: () {
                      //onstop
                    },
                  ),
                ] else if (selectedMode == FishtechyCameraMode.video) ...[
                  RecrodButton(
                    onVideoRecording: onVideoRecording,
                    onRecordStart: () {},
                    onRecordStopped: () {
                      onVideoStopped();
                    },
                  ),
                ] else
                  PhotoCaptureButton(
                    onTap: () {},
                  ),
                SizedBox(
                  width: 48,
                  child: ProofballDropdown(
                      colors: const [Colors.orange, Colors.red],
                      onChanged: (ball) {}),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String capitalizeFirstLetter(String word) {
  if (word.isEmpty) return word; // Return the word if it's empty
  return word[0].toUpperCase() + word.substring(1);
}
