import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:image/image.dart' as img;

/// Utility class for converting camera images to different formats
class ImageUtils {
  /// Converts an [AnalysisImage] to [img.Image] with robust handling
  static Future<img.Image?> convertToImage({
    required AnalysisImage image,
  }) async {
    final convertedImage = image.when(
      bgra8888: (bgra) async {
        return img.Image.fromBytes(
          width: bgra.width,
          height: bgra.height,
          bytes: bgra.planes[0].bytes.buffer,
          order: img.ChannelOrder.bgra,
        );
      },
      yuv420: (yuv) async {
        final jpeg = await yuv.toJpeg();
        return img.decodeJpg(jpeg.bytes);
      },
    );
    return convertedImage;
  }
}
