import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/frame_painter.dart';
import 'package:camerawesome_demo/new_camera/widgets/bottom_action_bar.dart';
import 'package:camerawesome_demo/new_camera/widgets/top_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPageView extends StatefulWidget {
  const CameraPageView({super.key});

  @override
  State<CameraPageView> createState() => _CameraPageViewState();
}

class _CameraPageViewState extends State<CameraPageView> {
  late CameraController _cameraController;
  late PageController _pageController;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;
  int _currentPage = 0;
  List<FishtechyCameraMode> availableModes = <FishtechyCameraMode>[];
  late PageController modePageController;
  FishtechyCameraMode _selectedMode = FishtechyCameraMode.photo;

  @override
  void initState() {
    super.initState();
    availableModes = FishtechyCameraMode.values;
    _pageController = PageController();
    modePageController = PageController(viewportFraction: 0.25, initialPage: 0);

    _pageController.addListener(_onPageChange);
    _initializeCamera();
  }

  void _onPageChange() {
    int newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      setState(() {
        _currentPage = newPage;
      });
      _onSelectionModeChanged(newPage);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _pageController.removeListener(_onPageChange);
    _pageController.dispose();
    super.dispose();
  }

  void _onSelectionModeChanged(int index) {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedMode = availableModes[index];
    });
    modePageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const Expanded(flex: 2, child: TopActionBar()),
          Expanded(
            flex: 15,
            child: PageView(
              controller: _pageController,
              children: [
                buildPreview(_cameraController),
                buildPreview(_cameraController),
                const SizedBox()
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: BottomActionBar(
              modePgController: modePageController,
              availableModes: availableModes,
              selectedMode: _selectedMode,
              onSelectionModeChanged: _onSelectionModeChanged,
              onModeTapped: (FishtechyCameraMode tab) {
                _onSelectionModeChanged(tab.index);
                _pageController.animateToPage(tab.index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
              onVideoRecording: (String? timer) {},
              onVideoStopped: () {},
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildPreview(CameraController controller) {
  return Stack(
    fit: StackFit.expand,
    children: [
      CameraPreview(controller),
      CustomPaint(
        painter: FramePainter(
          padding: CameraConstants.outerPadding,
          color: const Color.fromRGBO(0, 5, 34, 0.8),
        ),
        child: Container(
          margin: CameraConstants.outerPadding,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      )
    ],
  );
}
