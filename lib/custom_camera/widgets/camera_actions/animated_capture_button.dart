import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class AnimatedCaptureButton extends StatefulWidget {
  const AnimatedCaptureButton({
    super.key,
    required this.cameraState,
    required this.onVideoRecord,
  });
  final CameraState cameraState;
  final void Function(String?) onVideoRecord;

  @override
  State<AnimatedCaptureButton> createState() => _AnimatedCaptureButtonState();
}

class _AnimatedCaptureButtonState extends State<AnimatedCaptureButton> {
  bool _isRecording = false;
  int _timerSeconds = 0; // Timer value
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isRecording = widget.cameraState.captureState?.isRecordingVideo ?? false;
    });
  }

  void _startTimer() {
    _timerSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds++;
      });
      widget.onVideoRecord(_formattedTimer());
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
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
              widget.onVideoRecord(_formattedTimer());
            });
          },
          child: AnimatedContainer(
            padding: const EdgeInsets.all(6.0),
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isRecording ? Colors.white : Colors.red,
              ),
            ),
            duration: const Duration(milliseconds: 500),
            child: AnimatedContainer(
              margin:
                  _isRecording ? const EdgeInsets.all(10.0) : EdgeInsets.zero,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: _isRecording ? 20.0 : 48.0,
              height: _isRecording ? 20.0 : 48.0,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: _isRecording
                    ? BorderRadius.circular(4.0) // Rounded rectangle
                    : BorderRadius.circular(24.0), // Circle
              ),
            ),
          ),
        ),
        // if (_isRecording)
        //   AwesomeOrientedWidget(
        //     child: Padding(
        //       padding: const EdgeInsets.only(bottom: 60.0 + 22.0),
        //       child: Text(
        //         _formattedTimer(),
        //         style: context.headlineMedium.copyWith(
        //           fontWeight: FontWeight.w700,
        //           fontSize: 16.0,
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
