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
