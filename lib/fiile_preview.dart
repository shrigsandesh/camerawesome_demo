import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class FilePreviewWidget extends StatefulWidget {
  final String filePath;

  const FilePreviewWidget({super.key, required this.filePath});

  @override
  State<FilePreviewWidget> createState() => _FilePreviewWidgetState();
}

class _FilePreviewWidgetState extends State<FilePreviewWidget> {
  VideoPlayerController? _videoController;
  bool isVideo = false;

  @override
  void initState() {
    super.initState();
    _initializeFilePreview();
  }

  void _initializeFilePreview() {
    final fileExtension = widget.filePath.split('.').last.toLowerCase();
    if (['mp4', 'mov', 'avi', 'mkv'].contains(fileExtension)) {
      isVideo = true;
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          setState(() {});
          _videoController?.setLooping(true);
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isVideo) {
      return _videoController != null && _videoController!.value.isInitialized
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      return Image.file(
        File(widget.filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text("Failed to load image"));
        },
      );
    }
  }
}
