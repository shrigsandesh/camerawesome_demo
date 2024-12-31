import 'dart:async';
import 'package:flutter/material.dart';

class RecrodButton extends StatefulWidget {
  const RecrodButton({
    super.key,
    required this.onVideoRecording,
    required this.onRecordStart,
    required this.onRecordStopped,
    this.isRecording = false,
  });

  final VoidCallback onRecordStart;
  final VoidCallback onRecordStopped;

  final bool isRecording;

  final void Function(String?) onVideoRecording;

  @override
  State<RecrodButton> createState() => _RecrodButtonState();
}

class _RecrodButtonState extends State<RecrodButton> {
  bool _isRecording = false;
  int _timerSeconds = 0; // Timer value
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isRecording = widget.isRecording;
    });
  }

  void _startTimer() {
    _timerSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds++;
      });
      widget.onVideoRecording(_formattedTimer());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _timerSeconds = 0;
    });
    widget.onVideoRecording(_formattedTimer());
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
            if (_isRecording) {
              widget.onRecordStopped();
              setState(() {
                _isRecording = false;
              });
              _stopTimer();
            } else {
              setState(() {
                _isRecording = true;
              });
              _startTimer();
              widget.onRecordStart();
            }
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
      ],
    );
  }
}
