// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';

/// Represents the recognition output from the model
class Recognition {
  /// Index of the result
  final int classId;

  /// Confidence [0.0, 1.0]
  final double score;

  /// Location of bounding box rect
  ///
  /// The rectangle corresponds to the raw input image
  /// passed for inference
  final Rect normalizedRect;

  Recognition._({
    required this.classId,
    required this.score,
    required this.normalizedRect,
  });
  factory Recognition.fromTensorOutput({
    required List<double> output,
  }) {
    return Recognition._(
      classId: output[5].toInt(),
      score: output[4],
      normalizedRect: Rect.fromPoints(
        Offset(output[0], output[1]),
        Offset(output[2], output[3]),
      ),
    );
  }

  @override
  String toString() =>
      'Recognition(classId: $classId, score: $score, normalizedRect: $normalizedRect)';
}
