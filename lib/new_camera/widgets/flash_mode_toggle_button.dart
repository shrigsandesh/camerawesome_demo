import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FlashModeToggleButton extends StatefulWidget {
  final CameraController controller;

  const FlashModeToggleButton({super.key, required this.controller});

  @override
  State<FlashModeToggleButton> createState() => _FlashModeToggleButtonState();
}

class _FlashModeToggleButtonState extends State<FlashModeToggleButton> {
  FlashMode _currentFlashMode = FlashMode.off;

  Future<void> _toggleFlashMode() async {
    if (!widget.controller.value.isInitialized) return;

    FlashMode newFlashMode;
    switch (_currentFlashMode) {
      case FlashMode.off:
        newFlashMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newFlashMode = FlashMode.always;
        break;
      case FlashMode.always:
        newFlashMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newFlashMode = FlashMode.off;
        break;
    }

    await widget.controller.setFlashMode(newFlashMode);
    setState(() {
      _currentFlashMode = newFlashMode;
    });
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
      case FlashMode.off:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_getFlashIcon(), color: Colors.white),
      onPressed: _toggleFlashMode,
    );
  }
}
