import 'dart:async';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camerawesome/camerawesome_plugin.dart';

class VideoCaptureButton extends StatefulWidget {
  const VideoCaptureButton({super.key, required this.cameraState});
  final CameraState cameraState;

  @override
  State<VideoCaptureButton> createState() => _VideoCaptureButtonState();
}

class _VideoCaptureButtonState extends State<VideoCaptureButton> {
  int _timerSeconds = 0; // Timer value
  Timer? _timer;
  bool _isRecording = false;

  void _startTimer() {
    _timerSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _timerSeconds = 0;
    });
  }

  String _formattedTimer() {
    final minutes = (_timerSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timerSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRecording) ...[
              const SizedBox(
                height: 10.0,
              ),
              Text(
                _formattedTimer(),
                style: context.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.0,
                ),
              ),
            ],
            if (!_isRecording) const SizedBox(height: 20.0),
            InkWell(
              onTap: () {
                widget.cameraState.when(onVideoMode: (videoCameraState) {
                  // Start recording
                  videoCameraState.startRecording();
                  setState(() {
                    _isRecording = true;
                  });
                  _startTimer();
                }, onVideoRecordingMode: (videoRecordingCameraState) {
                  // Stop recording
                  videoRecordingCameraState.stopRecording();
                  setState(() {
                    _isRecording = false;
                  });
                  _stopTimer();
                });
              },
              child: _isRecording
                  ? SvgPicture.asset(
                      'assets/stop_video.svg',
                      height: 48.0,
                      width: 48.0,
                    )
                  : SvgPicture.asset(
                      'assets/video_lens.svg',
                      height: 48.0,
                      width: 48.0,
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
