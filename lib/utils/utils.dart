double normalizeZoom(double value, double minValue, double maxValue) {
  // Normalize the value using min-max normalization formula
  // (value - min) / (max - min)
  double normalizedValue = (value - minValue) / (maxValue - minValue);

  // Clamp the value between 0 and 1 to ensure it's in the desired range
  return normalizedValue.clamp(0.0, 1.0);
}
