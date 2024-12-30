import 'package:camerawesome_demo/custom_camera/widgets/camera_content.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // physics: const NeverScrollableScrollPhysics(),
        children: [
          CameraContent(pageController: _pageController),
          //TODO: replace with actual 3D camera view
          const _3DCameraWidget(),
        ],
      ),
    );
  }
}

// ignore: camel_case_types
class _3DCameraWidget extends StatelessWidget {
  const _3DCameraWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('3d camera view'),
    );
  }
}
