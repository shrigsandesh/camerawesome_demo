import 'package:flutter/services.dart';

Uint8List convertNV21ToBytes(int width, int height, Uint8List nv21Data) {
  // Ensure we have the correct amount of data
  final int frameSize = width * height;
  final int uvSize = (frameSize ~/ 2);

  if (nv21Data.length != frameSize + uvSize) {
    throw Exception(
        'Invalid NV21 data size. Expected ${frameSize + uvSize} but got ${nv21Data.length}');
  }

  // Create output buffer
  final Uint8List outputBuffer = Uint8List(frameSize * 4); // RGBA format

  // Process image
  int outputIndex = 0;

  // Convert each pixel
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * width + x;
      final int uvIndex = frameSize + (y ~/ 2) * width + (x & ~1);

      // Get Y value
      int yValue = nv21Data[yIndex] & 0xFF;

      // Get U and V values
      int vValue = nv21Data[uvIndex] & 0xFF;
      int uValue = nv21Data[uvIndex + 1] & 0xFF;

      // Convert YUV to RGB
      int y1192 = 1192 * (yValue - 16);
      int r = (y1192 + 1634 * (vValue - 128)) ~/ 1024;
      int g = (y1192 - 833 * (vValue - 128) - 400 * (uValue - 128)) ~/ 1024;
      int b = (y1192 + 2066 * (uValue - 128)) ~/ 1024;

      // Clamp RGB values
      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      // Write RGBA values
      outputBuffer[outputIndex++] = r;
      outputBuffer[outputIndex++] = g;
      outputBuffer[outputIndex++] = b;
      outputBuffer[outputIndex++] = 255; // Alpha channel
    }
  }

  return outputBuffer;
}
