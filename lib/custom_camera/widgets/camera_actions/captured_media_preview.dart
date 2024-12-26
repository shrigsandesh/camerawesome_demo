import 'dart:developer';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CapturedMediaPreview extends StatelessWidget {
  final MediaCapture? mediaCapture;
  final OnMediaTap onMediaTap;
  final CameraState state;

  const CapturedMediaPreview({
    super.key,
    required this.mediaCapture,
    required this.onMediaTap,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return AwesomeOrientedWidget(
      child: AspectRatio(
        aspectRatio: 1,
        child: AwesomeBouncingWidget(
          onTap: mediaCapture != null &&
                  onMediaTap != null &&
                  mediaCapture?.status == MediaCaptureStatus.success
              ? () => onMediaTap!(mediaCapture!)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: _buildMedia(mediaCapture, state)),
          ),
        ),
      ),
    );
  }

  Widget _buildMedia(MediaCapture? mediaCapture, CameraState state) {
    switch (mediaCapture?.status) {
      case MediaCaptureStatus.capturing:
        if (mediaCapture?.isVideo ?? false) {
          return InkWell(
            onTap: () {
              state.when(onVideoRecordingMode: (vState) {
                log("on recording mode");
                if (mediaCapture?.isRecordingVideo ?? false) {
                  vState.pauseRecording(mediaCapture!);
                } else {
                  vState.resumeRecording(mediaCapture!);
                }
              }, onVideoMode: (videoState) {
                log("on video mode");

                // videoState.captureState.is
              }, onPreviewMode: (pmode) {
                log("on video mode");
              });
            },
            child: Icon(
              (mediaCapture?.isRecordingVideo ?? false)
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
            ),
          );
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Platform.isIOS
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                  )
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  ),
          ),
        );
      case MediaCaptureStatus.success:
        if (mediaCapture!.isPicture) {
          return Image(
            fit: BoxFit.cover,
            image: ResizeImage(
              FileImage(
                File(
                  mediaCapture.captureRequest.when(
                    single: (single) => single.file!.path,
                    multiple: (multiple) =>
                        multiple.fileBySensor.values.first!.path,
                  ),
                ),
              ),
              width: 300,
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(10.0)),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
            ),
          );
        }
      case MediaCaptureStatus.failure:
        return const Icon(
          Icons.error,
          color: Colors.white,
        );
      case null:
        return const SizedBox(
          width: 32,
          height: 32,
        );
    }
  }
}
