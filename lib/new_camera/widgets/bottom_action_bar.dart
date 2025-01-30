import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/new_camera/widgets/photo_capture_button.dart';
import 'package:camerawesome_demo/new_camera/widgets/record_button.dart';
import 'package:camerawesome_demo/new_camera/widgets/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.modePgController,
    required this.availableModes,
    required this.selectedMode,
    required this.onModeChanged,
    required this.onVideoRecording,
    required this.onVideoStopped,
    required this.controller,
  });

  final PageController modePgController;
  final List<FishtechyCameraMode> availableModes;
  final FishtechyCameraMode selectedMode;
  final void Function(FishtechyCameraMode tab) onModeChanged;
  final void Function(String? timer) onVideoRecording;
  final VoidCallback onVideoStopped;
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Column(
        children: [
          SizedBox(
            height: 32,
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: modePgController,
              onPageChanged: (index) {
                onModeChanged(availableModes[index]);
              },
              children: availableModes
                  .map(
                    (tab) => Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: tab.name == selectedMode.name ? 1 : 0.2,
                        child: BouncingWidget(
                          duration: const Duration(milliseconds: 300),
                          onTap: () => onModeChanged(tab),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                tab.displayName,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (selectedMode == FishtechyCameraMode.threeD) ...[
                  RecordButton(
                    onVideoRecording: onVideoRecording,
                    isRecording: controller.value.isRecordingVideo,
                    onRecordStart: () {
                      controller.startVideoRecording();
                    },
                    onRecordStopped: () async {
                      onVideoStopped();
                      final file = await controller.takePicture();
                      await Gal.putVideo(file.path, album: 'FlyTechy');
                    },
                  ),
                ] else if (selectedMode == FishtechyCameraMode.video) ...[
                  RecordButton(
                    onVideoRecording: onVideoRecording,
                    isRecording: controller.value.isRecordingVideo,
                    onRecordStart: () {
                      controller.startVideoRecording();
                    },
                    onRecordStopped: () {
                      onVideoStopped();
                      saveVideo();
                    },
                  ),
                ] else
                  PhotoCaptureButton(
                    onTap: () {
                      savePhoto();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void saveVideo() async {
    try {
      final file = await controller.stopVideoRecording();
      String newPath = file.path.replaceAll('.temp', '.mp4');
      log(file.path);

      File newFile = File(file.path);
      final renamedFile = await newFile.rename(newPath);
      await Gal.putVideo(renamedFile.path, album: 'FlyTechy');
      log("successfully saved video to gallery");
    } catch (e) {
      log(e.toString());
    }
  }

  void savePhoto() async {
    try {
      final file = await controller.takePicture();
      await Gal.putImage(file.path, album: 'FlyTechy');
      log("successfully saved photo to gallery");
    } catch (e) {
      log("error saving file");
    }
  }
}
