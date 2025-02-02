// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:camerawesome_demo/custom_camera/tflite/ml_processing_stats.dart';
import 'package:camerawesome_demo/custom_camera/tflite/ml_recognition.dart';

class MlProcessingResult {
  final List<MlRecognition> recognitions;
  final MlProcessingStats stats;

  MlProcessingResult({
    required this.recognitions,
    required this.stats,
  });

  @override
  String toString() =>
      'MlProcessingResult(recognitions: $recognitions, stats: $stats)';
}

enum MlRecognitionWindowStatus {
  noObject,
  noBall,
  noFish,
  fishAndBallOffCenter,
  fishOffCenter,
  ballOffCenter,
  allGood,
}

extension MlRecognitionWindowStatusX on MlRecognitionWindowStatus {
  String get message => switch (this) {
        MlRecognitionWindowStatus.noObject => "No object detected",
        MlRecognitionWindowStatus.noFish => "No fish detected",
        MlRecognitionWindowStatus.noBall => "No ball detected",
        MlRecognitionWindowStatus.fishOffCenter =>
          "Place the fish inside the frame",
        MlRecognitionWindowStatus.ballOffCenter =>
          "Center the ball inside the frame",
        MlRecognitionWindowStatus.fishAndBallOffCenter =>
          "Center the fish and ball inside the frame",
        MlRecognitionWindowStatus.allGood => "All good",
      };
}

extension MlProcessingResultX on MlProcessingResult {
  MlRecognitionWindowStatus getDetectionStatuses({
    required Rect containerRect,
    required Size renderSize,
  }) {
    if (recognitions.isEmpty) {
      return MlRecognitionWindowStatus.noObject;
    }

    final fishMlRecognitions =
        recognitions.where((e) => e.type == MlRecognitionType.fish);
    final ballMlRecognitions =
        recognitions.where((e) => e.type == MlRecognitionType.ball);

    final hasFish = fishMlRecognitions.isNotEmpty;
    final hasBall = ballMlRecognitions.isNotEmpty;
    if (!hasFish && !hasBall) {
      return MlRecognitionWindowStatus.noObject;
    }

    if (!hasFish) {
      return MlRecognitionWindowStatus.noFish;
    }

    if (!hasBall) {
      return MlRecognitionWindowStatus.noBall;
    }
    final fishInside = fishMlRecognitions.every(
      (e) => containerRect.totallyContains(
        e.renderRect(renderSize: renderSize),
      ),
    );

    final ballContainerRect = Rect.fromCenter(
      center: containerRect.center,
      width: containerRect.width / 2,
      height: containerRect.height / 2,
    );

    final ballInside = ballMlRecognitions.every(
      (e) => ballContainerRect.totallyContains(
        e.renderRect(renderSize: renderSize),
      ),
    );
    if (!fishInside && !ballInside) {
      return MlRecognitionWindowStatus.fishAndBallOffCenter;
    }
    if (!fishInside) {
      return MlRecognitionWindowStatus.fishOffCenter;
    }
    if (!ballInside) {
      return MlRecognitionWindowStatus.ballOffCenter;
    }

    return MlRecognitionWindowStatus.allGood;
  }
}

extension RectContainX on Rect {
  bool totallyContains(Rect other) {
    return contains(other.topLeft) &&
        contains(other.topRight) &&
        contains(other.bottomLeft) &&
        contains(other.bottomRight);
  }
}
