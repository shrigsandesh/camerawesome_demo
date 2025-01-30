import 'dart:math' as math;
import 'dart:ui';

import 'package:camerawesome_demo/custom_camera/tflite/recognition.dart';
import 'package:collection/collection.dart';

/// Extension on [Rect] to provide Intersection over Union (IoU) calculations
extension RectIou on Rect {
  /// Calculates Intersection over Union (IoU) between two bounding boxes
  ///
  /// IoU measures overlap between two rectangular regions
  /// - Returns a value between 0 (no overlap) and 1 (perfect overlap)
  double iou(Rect other) {
    double i = intersectionArea(other);
    double u = unionArea(other);
    return i / u;
  }

  /// Calculates the area of intersection between two rectangles
  double intersectionArea(Rect other) {
    double w = (math.min(right, other.right) - math.max(left, other.left))
        .clamp(0.0, double.infinity);
    double h = (math.min(bottom, other.bottom) - math.max(top, other.top))
        .clamp(0.0, double.infinity);
    return w * h;
  }

  /// Calculates the union area of two rectangles
  double unionArea(Rect other) {
    double i = intersectionArea(other);
    return area + other.area - i;
  }

  /// Calculates the area of the rectangle
  double get area => width * height;
}

class NmsUtils {
  /// A constant representing the IoU threshold for suppression
  /// Boxes with IoU above this threshold are suppressed
  static const double mNmsThresh = 0.5;

  NmsUtils._();

  /// Performs Non-Maximum Suppression (NMS) on a list of [Recognition]
  ///
  /// NMS filters overlapping bounding boxes by their confidence scores
  /// - Retains only the highest-scoring boxes for each class
  /// - Suppresses boxes with IoU exceeding the threshold
  ///
  /// [list] A list of recognition objects to process
  /// Returns a list of filtered recognition objects
  static List<Recognition> nmsForAllClasses(List<Recognition> list) {
    Map<int, PriorityQueue<Recognition>> classMap = {};
    List<Recognition> nmsList = [];

    // 1. Group recognitions by class
    for (final recognition in list) {
      classMap
          .putIfAbsent(
              recognition.classId,
              () => HeapPriorityQueue<Recognition>(
                  (a, b) => b.score.compareTo(a.score)))
          .add(recognition);
    }

    // 2. Perform NMS for each class separately
    for (var pq in classMap.values) {
      while (pq.isNotEmpty) {
        final max = pq.removeFirst();
        nmsList.add(max);

        final remainingDetections = pq.toList();
        pq.clear();

        for (final detection in remainingDetections) {
          if (max.rect.iou(detection.rect) < mNmsThresh) {
            pq.add(detection);
          }
        }
      }
    }

    return nmsList;
  }
}
