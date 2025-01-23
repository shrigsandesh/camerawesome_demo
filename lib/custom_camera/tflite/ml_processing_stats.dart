class MlProcessingStats {
  /// Total time taken to convert [AnalyseImage] to [img.Image]
  int conversionTime;

  /// [totalPredictTime] + communication overhead time
  /// between main isolate and another isolate
  int totalElapsedTime;

  /// Time for which inference runs
  int inferenceTime;

  /// Time taken to pre-process the image
  int preProcessingTime;

  MlProcessingStats({
    required this.conversionTime,
    required this.totalElapsedTime,
    required this.inferenceTime,
    required this.preProcessingTime,
  });

  @override
  String toString() {
    return 'MlProcessingStats{conversionTime: $conversionTime, totalElapsedTime: $totalElapsedTime, inferenceTime: $inferenceTime, preProcessingTime: $preProcessingTime}';
  }
}
