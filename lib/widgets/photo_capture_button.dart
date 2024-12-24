import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class PhotoCaptureButton extends StatefulWidget {
  const PhotoCaptureButton({
    super.key,
    this.size = 72,
    required this.state,
  });
  final double size;
  final CameraState state;

  @override
  State<PhotoCaptureButton> createState() => _PhotoCaptureButtonState();
}

class _PhotoCaptureButtonState extends State<PhotoCaptureButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Indicator
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 4,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),

            // Capture Button
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  widget.state.setState(CaptureMode.photo);
                  widget.state.when(
                    onPhotoMode: (cameraState) => cameraState.takePhoto(),
                  );
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey[300],
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
