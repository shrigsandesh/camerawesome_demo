import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  // Get Android SDK version
  static Future<int> _getAndroidSDKVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  // Request media permissions based on Android version
  static Future<bool> requestMediaPermissions() async {
    if (!Platform.isAndroid) {
      // Handle iOS permissions
      return await Permission.photos.request().isGranted;
    }

    // Get Android SDK version
    final sdkVersion = await _getAndroidSDKVersion();

    // Android 13 and above (API level 33+)
    if (sdkVersion >= 33) {
      final photos = await Permission.photos.request();
      final videos = await Permission.videos.request();
      return photos.isGranted && videos.isGranted;
    }

    // Android 12 and below (API level 32 and below)
    else {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
  }

  // Check if the app has required permissions
  static Future<bool> hasRequiredPermissions() async {
    if (!Platform.isAndroid) {
      return await Permission.photos.status.isGranted;
    }

    final sdkVersion = await _getAndroidSDKVersion();

    if (sdkVersion >= 33) {
      return await Permission.photos.status.isGranted &&
          await Permission.videos.status.isGranted;
    } else {
      return await Permission.storage.status.isGranted;
    }
  }

  // Handle permanently denied permissions
  Future<void> handlePermanentlyDenied() async {
    if (!Platform.isAndroid) {
      if (await Permission.photos.isPermanentlyDenied) {
        openAppSettings();
      }
      return;
    }

    final sdkVersion = await _getAndroidSDKVersion();

    if (sdkVersion >= 33) {
      if (await Permission.photos.isPermanentlyDenied ||
          await Permission.videos.isPermanentlyDenied) {
        openAppSettings();
      }
    } else {
      if (await Permission.storage.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }
}
