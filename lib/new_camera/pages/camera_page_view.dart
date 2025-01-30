import 'package:camerawesome_demo/custom_camera/constants/camera_constants.dart';
import 'package:camerawesome_demo/custom_camera/painters/frame_painter.dart';
import 'package:camerawesome_demo/new_camera/widgets/bottom_action_bar.dart';
import 'package:camerawesome_demo/new_camera/widgets/top_action_bar.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
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
  List<FishtechyCameraMode> availableModes = <FishtechyCameraMode>[];
  late PageController modePageController;
  FishtechyCameraMode _selectedMode = FishtechyCameraMode.photo;

  @override
  void initState() {
    super.initState();
    availableModes = [
      FishtechyCameraMode.photo,
      FishtechyCameraMode.video,
    ];
    _pageController = PageController();
    modePageController = PageController(viewportFraction: 0.25, initialPage: 0);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      _cameraController = CameraController(
        _cameras[0],
        ResolutionPreset.medium,
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
    modePageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSelectionModeChanged({
    required FishtechyCameraMode mode,
    required bool updateMode,
    required bool updatePage,
  }) {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedMode = mode;
    });
    if (updatePage) {
      _pageController.animateToPage(
        mode.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
    if (updateMode) {
      modePageController.animateToPage(
        mode.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
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
          const Spacer(),
          const TopActionBar(),
          const Spacer(
            flex: 2,
          ),
          Center(
            child: ExpandablePageView(
              onPageChanged: (index) {
                _onSelectionModeChanged(
                  mode: availableModes[index],
                  updateMode: true,
                  updatePage: true,
                );
              },
              controller: _pageController,
              children: availableModes
                  .map((e) => switch (e) {
                        FishtechyCameraMode.photo ||
                        FishtechyCameraMode.video =>
                          buildPreview(_cameraController),
                        FishtechyCameraMode.threeD => const SizedBox(
                            height: 500,
                          ),
                      })
                  .toList(),
            ),
          ),
          const Spacer(
            flex: 3,
          ),
          BottomActionBar(
            modePgController: modePageController,
            availableModes: availableModes,
            selectedMode: _selectedMode,
            onModeChanged: (mode) {
              _onSelectionModeChanged(
                mode: mode,
                updateMode: true,
                updatePage: true,
              );
            },
            onVideoRecording: (String? timer) {},
            onVideoStopped: () {},
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

Widget buildPreview(CameraController controller) {
  return AspectRatio(
    aspectRatio: 1 / controller.value.aspectRatio,
    child: Stack(
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
    ),
  );
}
