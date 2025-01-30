import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class PhotoCaptureButton extends StatelessWidget {
  const PhotoCaptureButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AwesomeBouncingWidget(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6.0),
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
          ),
        ),
        child: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0), // Circle
          ),
        ),
      ),
    );
  }
}
