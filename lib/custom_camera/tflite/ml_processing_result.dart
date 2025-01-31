// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:camerawesome_demo/custom_camera/tflite/ml_processing_stats.dart';
import 'package:camerawesome_demo/custom_camera/tflite/recognition.dart';

class MlProcessingResult {
  final List<Recognition> recognitions;
  final MlProcessingStats stats;

  MlProcessingResult({
    required this.recognitions,
    required this.stats,
  });

  @override
  String toString() =>
      'MlProcessingResult(recognitions: $recognitions, stats: $stats)';
}

/// Extension to provide helper methods for `MlProcessingResult`
extension MlProcessingResultX on MlProcessingResult {
  /// Returns a status message based on detected objects.
  String getDetectionStatus({
    required Rect containerRect,
    required Size renderSize,
  }) {
    if (recognitions.isEmpty) {
      return "No object detected";
    }

    final fishRecognitions = recognitions.where((e) => e.classId == 0);
    final ballRecognitions = recognitions.where((e) => e.classId == 1);

    final hasFish = fishRecognitions.isNotEmpty;
    final hasBall = ballRecognitions.isNotEmpty;

    bool isFullyInside(Rect rect) {
      return containerRect.contains(rect.topLeft) &&
          containerRect.contains(rect.topRight) &&
          containerRect.contains(rect.bottomLeft) &&
          containerRect.contains(rect.bottomRight);
    }

    final fishInside = fishRecognitions.every(
      (e) => isFullyInside(
        e.renderRect(
          renderSize: renderSize,
        ),
      ),
    );
    final ballInside = ballRecognitions.every(
      (e) => isFullyInside(
        e.renderRect(
          renderSize: renderSize,
        ),
      ),
    );

    if (!hasFish && !hasBall) return "No object detected";
    if (!hasFish) return "No fish detected";
    if (!hasBall) return "No ball detected";

    if (!fishInside && !ballInside) {
      return "Center the fish and ball inside the frame";
    }
    if (!fishInside) {
      return "Center the fish inside the frame";
    }
    if (!ballInside) {
      return "Center the ball inside the frame";
    }

    return "Fish and Ball detected";
  }
}
