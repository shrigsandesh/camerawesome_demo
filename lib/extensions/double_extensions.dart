extension NullableDoubleExtension on double? {
  /// Returns the integer value as a string if the double is a whole number.
  /// Otherwise, returns the double formatted with one decimal place.
  String toFormattedString() {
    if (this == null) {
      return 'null';
    }
    return this! % 1 == 0 ? this!.toInt().toString() : this!.toStringAsFixed(1);
  }
}
