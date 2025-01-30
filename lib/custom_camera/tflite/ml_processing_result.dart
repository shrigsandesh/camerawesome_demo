// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  String get detectionStatus {
    if (recognitions.isEmpty) {
      return "No object detected";
    }

    final hasFish = recognitions.any((e) => e.classId == 0);
    final hasBall = recognitions.any((e) => e.classId == 1);

    if (!hasFish && !hasBall) return "No object detected";
    if (!hasFish) return "No fish detected";
    if (!hasBall) return "No ball detected";

    return "Fish and Ball detected";
  }
}
