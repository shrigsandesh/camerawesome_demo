// import 'dart:io';
// import 'dart:isolate';
// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:camerawesome_demo/custom_camera/utils/utils.dart';
// import 'package:camerawesome_demo/extensions/mlkit_extension.dart';
// import 'package:image/image.dart' as image_lib;

// import 'package:tflite_flutter/tflite_flutter.dart';

// /// Manages separate Isolate instance for inference
// class IsolateUtils {
//   static const String debugName = "InferenceIsolate";

//   Isolate? _isolate;
//   final ReceivePort _receivePort = ReceivePort();
//   SendPort? _sendPort;

//   /// Getter for the send port
//   SendPort? get sendPort => _sendPort;

//   /// Initializes and starts the isolate
//   Future<void> start() async {
//     try {
//       _isolate = await Isolate.spawn<SendPort>(
//         entryPoint,
//         _receivePort.sendPort,
//         debugName: debugName,
//       );

//       _sendPort = await _receivePort.first as SendPort;
//     } catch (e) {
//       throw Exception('Failed to start isolate: $e');
//     }
//   }

//   /// Stops the isolate and cleans up resources
//   void dispose() {
//     _receivePort.close();
//     _isolate?.kill();
//   }

//   /// Entry point for the isolate
//   static Future<void> entryPoint(SendPort sendPort) async {
//     final port = ReceivePort();
//     sendPort.send(port.sendPort);

//     await for (final IsolateData? isolateData in port) {
//       if (isolateData == null) continue;

//       try {
//         final classifier = Classifier(
//           interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
//           labels: isolateData.labels,
//         );

//         var analysisImg = isolateData.cameraImage.toInputImage();
//         var processedImage = AnalysisImage.from(map)
         

//         if (Platform.isAndroid) {
//           processedImage = image_lib.copyRotate(processedImage, angle: 90);
//         }

//         final results = classifier.predict(processedImage);
//         isolateData.responsePort.send(results);
//       } catch (e) {
//         isolateData.responsePort.send({'error': e.toString()});
//       }
//     }
//   }
// }

// /// Data class for passing information between isolates
// class IsolateData {
//   final AnalysisImage cameraImage;
//   final int interpreterAddress;
//   final List<String> labels;
//   final SendPort responsePort;

//   IsolateData({
//     required this.cameraImage,
//     required this.interpreterAddress,
//     required this.labels,
//     required this.responsePort,
//   });
// }
