// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:camerawesome_demo/custom_camera/tflite/ml_processing_result.dart';
import 'package:flutter/cupertino.dart';

/// Represents the recognition output from the model
class Recognition implements Comparable<Recognition> {
  /// Index of the result
  final int classId;

  /// Confidence [0.0, 1.0]
  final double score;

  /// Location of bounding box rect
  ///
  /// The rectangle corresponds to the raw input image
  /// passed for inference
  final Rect rect;

  Recognition._({
    required this.classId,
    required this.score,
    required this.rect,
  });

  /// Creates a `Recognition` object from tensor output
  factory Recognition.fromFlatOutput({
    required List<double> output,
  }) {
    return Recognition._(
      rect: Rect.fromPoints(
        Offset(output[0], output[1]),
        Offset(output[2], output[3]),
      ),
      score: output[4],
      classId: output[5].toInt(),
    );
  }

  /// Compares `Recognition` objects based on their `score`
  @override
  int compareTo(Recognition other) {
    return score.compareTo(other.score);
  }

  Rect renderRect({
    required Size renderSize,
  }) {
    log(renderSize.toString());
    // Calculate scaling factors for rendering
    double scaleX = renderSize.width;
    double scaleY = renderSize.height;

    // Scale and transform the original rect
    return Rect.fromLTRB(
      rect.left * scaleX,
      rect.top * scaleY,
      rect.right * scaleX,
      rect.bottom * scaleY,
    );
  }

  @override
  String toString() {
    return 'Recognition(classId: $classId, score: $score, rect: $rect)';
  }
}
