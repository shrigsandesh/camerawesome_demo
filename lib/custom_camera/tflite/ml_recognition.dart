// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';

/// Represents the recognition output from the model
class MlRecognition implements Comparable<MlRecognition> {
  /// Index of the result
  final MlRecognitionType type;

  /// Confidence [0.0, 1.0]
  final double score;

  /// Location of bounding box rect
  ///
  /// The rectangle corresponds to the raw input image
  /// passed for inference
  final Rect rect;

  MlRecognition._({
    required this.type,
    required this.score,
    required this.rect,
  });

  /// Creates a `MlRecognition` object from tensor output
  factory MlRecognition.fromFlatOutput({
    required List<double> output,
  }) {
    return MlRecognition._(
      rect: Rect.fromPoints(
        Offset(output[0], output[1]),
        Offset(output[2], output[3]),
      ),
      score: output[4],
      type: MlRecognitionType.values.firstWhere(
        (e) => e.classId == output[5].toInt(),
        orElse: () {
          return MlRecognitionType.ball;
        },
      ),
    );
  }

  /// Compares `MlRecognition` objects based on their `score`
  @override
  int compareTo(MlRecognition other) {
    return score.compareTo(other.score);
  }

  Rect renderRect({
    required Size renderSize,
  }) {
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
  String toString() => 'MlRecognition(type: $type, score: $score, rect: $rect)';
}

enum MlRecognitionType { fish, ball }

extension MlRecognitionTypeX on MlRecognitionType {
  int get classId => switch (this) {
        MlRecognitionType.fish => 0,
        MlRecognitionType.ball => 1,
      };
}
