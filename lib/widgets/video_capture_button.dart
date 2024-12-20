import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class VideoCaptureButton extends StatefulWidget {
  const VideoCaptureButton(
      {super.key,
      this.size = 72,
      required this.state,
      required this.captureDuration,
      this.onTimerComplete,
      this.onTimerStart});
  final double size;
  final CameraState state;
  final Duration captureDuration;
  final VoidCallback? onTimerComplete;
  final VoidCallback? onTimerStart;

  @override
  State<VideoCaptureButton> createState() => _VideoCaptureButtonState();
}

class _VideoCaptureButtonState extends State<VideoCaptureButton> {
  int _timeLeft = 5;
  double _progress = 0;
  Timer? _timer;
  Timer? _progressTimer;

  bool _isActive = false;

  // bool get _isActive => widget.state.captureState?.isRecordingVideo ?? false;

  void startTimer() {
    const progressUpdateInterval = 50; // Update every 50ms for smooth animation
    final totalSteps =
        (widget.captureDuration.inMilliseconds / progressUpdateInterval).ceil();
    int currentStep = 0;
    setState(() {
      _isActive = true;
      _timeLeft = widget.captureDuration.inSeconds;
      _progress = 0.0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _progressTimer?.cancel();

          _isActive = false;
          widget.onTimerComplete?.call();
          widget.state.when(
            onVideoRecordingMode: (videoState) => videoState.stopRecording(),
          );
        }
      });
    });

    _progressTimer = Timer.periodic(
        const Duration(milliseconds: progressUpdateInterval), (timer) {
      if (currentStep < totalSteps) {
        setState(() {
          currentStep++;
          _progress = currentStep / totalSteps;
        });
      } else {
        _progressTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer Text
        if (_isActive)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(formatDuration(_timeLeft),
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),

        // Capture Button with Progress Indicator
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular Progress Indicator
            SizedBox(
              width: 80,
              height: 80,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_isActive),
                tween: Tween<double>(begin: 0.0, end: _progress),
                duration: const Duration(milliseconds: 250),
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isActive ? Colors.red : Colors.transparent,
                    ),
                  );
                },
              ),
            ),

            // Capture Button
            Material(
              color: _isActive ? Colors.grey[300] : Colors.red,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _isActive
                    ? null
                    : () {
                        startTimer();
                        widget.state.setState(CaptureMode.video);
                        widget.state.when(
                          onPhotoMode: (cameraState) => cameraState.takePhoto(),
                          onVideoMode: (videoCameraState) =>
                              videoCameraState.startRecording(),
                          onVideoRecordingMode: (videoRecordingCameraState) =>
                              videoRecordingCameraState.stopRecording(),
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
                    color: _isActive ? Colors.grey : Colors.white,
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

String formatDuration(int seconds) {
  final minutes = (seconds / 60).floor();
  final remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
