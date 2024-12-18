import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/top_control_widget.dart';
import 'package:camerawesome_demo/zoom_control_widget.dart';

import 'package:flutter/material.dart';

class CustomCameraUi extends StatelessWidget {
  const CustomCameraUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.custom(
        builder: (cameraState, preview) {
          return Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 50, horizontal: 10),
                        child: TopControlWidget(
                          state: cameraState,
                        ),
                      ),
                      const Spacer(),
                      ZoomControlWidget(
                        state: cameraState,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ColoredBox(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    cameraState.switchCameraSensor();
                                  },
                                  icon: const Icon(
                                    Icons.cameraswitch_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    cameraState.when(
                                        onPhotoMode: (picState) =>
                                            picState.takePhoto());
                                  },
                                  icon: const Icon(
                                    Icons.camera,
                                    color: Colors.white,
                                    size: 72,
                                  )),
                              SizedBox(
                                width: 45,
                                child: StreamBuilder<MediaCapture?>(
                                  stream: cameraState.captureState$,
                                  builder: (_, snapshot) {
                                    if (snapshot.data == null) {
                                      return const SizedBox.shrink();
                                    }
                                    return AwesomeMediaPreview(
                                      mediaCapture: snapshot.data!,
                                      onMediaTap: (MediaCapture mediaCapture) {
                                        // ignore: avoid_print
                                        print("Tap on $mediaCapture");
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        saveConfig: SaveConfig.photoAndVideo(),
      ),
    );
  }
}
