// ignore_for_file: public_member_api_docs, sort_constructors_first
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
  final int refHeight;
  final int refWidth;

  Recognition._({
    required this.classId,
    required this.score,
    required this.rect,
    required this.refWidth,
    required this.refHeight,
  });

  /// Creates a `Recognition` object from tensor output
  factory Recognition.fromFlatOutput({
    required List<double> output,
    required int imageHeight,
    required int imageWidth,
  }) {
    return Recognition._(
      rect: Rect.fromPoints(
        Offset(output[0] * imageWidth, output[1] * imageHeight),
        Offset(output[2] * imageWidth, output[3] * imageHeight),
      ),
      refHeight: imageHeight,
      refWidth: imageWidth,
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
    // Calculate scaling factors for rendering
    double scaleX = renderSize.width / refWidth;
    double scaleY = renderSize.height / refHeight;

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
    return 'Recognition(classId: $classId, score: $score, rect: $rect, refHeight: $refHeight, refWidth: $refWidth)';
  }
}
