import 'package:camerawesome_demo/custom_camera/widgets/camera_content.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Camera',
          style: context.headlineMedium,
        ),
      ),
      body: const CameraContent(),
    );
  }
}
