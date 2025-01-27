import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/tflite/ml_processing_result.dart';
import 'package:camerawesome_demo/custom_camera/tflite/ml_processing_stats.dart';
import 'package:camerawesome_demo/custom_camera/tflite/recognition.dart';
import 'package:camerawesome_demo/custom_camera/utils/image_utils.dart';
import 'package:camerawesome_demo/custom_camera/utils/nms_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

///////////////////////////////////////////////////////////////////////////////
//
// The following Detector example works by spawning a background isolate and
// communicating with it over Dart's SendPort API. It is presented below as a
// demonstration of the feature "Background Isolate Channels" and shows using
// plugins from a background isolate. The [Detector] operates on the root
// isolate and the [_DetectorServer] operates on a background isolate.
//
// Here is an example of the protocol they use to communicate:
//
//  _________________                         ________________________
//  [:Detector]                               [:_DetectorServer]
//  -----------------                         ------------------------
//         |                                              |
//         |<---------------(init)------------------------|
//         |----------------(init)----------------------->|
//         |<---------------(ready)---------------------->|
//         |                                              |
//         |----------------(detect)--------------------->|
//         |<---------------(busy)------------------------|
//         |<---------------(result)----------------------|
//         |                 . . .                        |
//         |----------------(detect)--------------------->|
//         |<---------------(busy)------------------------|
//         |<---------------(result)----------------------|
//
///////////////////////////////////////////////////////////////////////////////

/// All the command codes that can be sent and received between [Detector] and
/// [_DetectorServer].
enum _Codes {
  init,
  busy,
  ready,
  detect,
  result,
}

/// A command sent between [Detector] and [_DetectorServer].
class _Command {
  const _Command(this.code, {this.args});

  final _Codes code;
  final List<Object>? args;
}

/// A Simple Detector that handles object detection via Service
///
/// All the heavy operations like pre-processing, detection, ets,
/// are executed in a background isolate.
/// This class just sends and receives messages to the isolate.
class Detector {
  static const String _modelPath =
      'assets/ml/pball_imgsz_200_yolov10_32.tflite';

  Detector._(this._isolate, this._interpreter);

  final Isolate _isolate;
  late final Interpreter _interpreter;

  // To be used by detector (from UI) to send message to our Service ReceivePort
  late final SendPort _sendPort;

  bool _isReady = false;

  // // Similarly, StreamControllers are stored in a queue so they can be handled
  // // asynchronously and serially.
  final StreamController<MlProcessingResult> resultsStream =
      StreamController<MlProcessingResult>();

  /// Open the database at [path] and launch the server on a background isolate..
  static Future<Detector> start() async {
    final ReceivePort receivePort = ReceivePort();
    // sendPort - To be used by service Isolate to send message to our ReceiverPort
    final Isolate isolate =
        await Isolate.spawn(_DetectorServer._run, receivePort.sendPort);

    final Detector result = Detector._(
      isolate,
      await _loadModel(),
    );
    receivePort.listen((message) {
      result._handleCommand(message as _Command);
    });
    return result;
  }

  static Future<Interpreter> _loadModel() async {
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate
    // if (Platform.isAndroid) {
    //   interpreterOptions.addDelegate(XNNPackDelegate());
    // } else if (Platform.isIOS) {
    //   interpreterOptions.addDelegate(GpuDelegate());
    // }

    return Interpreter.fromAsset(
      _modelPath,
      options: interpreterOptions..threads = 4,
    );
  }

  /// Starts AnalysisImage processing
  void processFrame(AnalysisImage cameraImage) {
    if (_isReady) {
      _sendPort.send(_Command(_Codes.detect, args: [cameraImage]));
    }
  }

  /// Handler invoked when a message is received from the port communicating
  /// with the database server.
  void _handleCommand(_Command command) {
    switch (command.code) {
      case _Codes.init:
        _sendPort = command.args?[0] as SendPort;
        // ----------------------------------------------------------------------
        // Before using platform channels and plugins from background isolates we
        // need to register it with its root isolate. This is achieved by
        // acquiring a [RootIsolateToken] which the background isolate uses to
        // invoke [BackgroundIsolateBinaryMessenger.ensureInitialized].
        // ----------------------------------------------------------------------
        RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
        _sendPort.send(_Command(_Codes.init, args: [
          rootIsolateToken,
          _interpreter.address,
        ]));
      case _Codes.ready:
        _isReady = true;
      case _Codes.busy:
        _isReady = false;
      case _Codes.result:
        _isReady = true;
        resultsStream.add(command.args?[0] as MlProcessingResult);
      default:
        debugPrint('Detector unrecognized command: ${command.code}');
    }
  }

  /// Kills the background isolate and its detector server.
  void stop() {
    _isolate.kill();
  }
}

/// The portion of the [Detector] that runs on the background isolate.
///
/// This is where we use the new feature Background Isolate Channels, which
/// allows us to use plugins from background isolates.
class _DetectorServer {
  List<int> inputShape = [];
  List<int> outputShape = [];
  Interpreter? _interpreter;

  _DetectorServer(this._sendPort);

  final SendPort _sendPort;

  // ----------------------------------------------------------------------
  // Here the plugin is used from the background isolate.
  // ----------------------------------------------------------------------

  /// The main entrypoint for the background isolate sent to [Isolate.spawn].
  static void _run(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    final _DetectorServer server = _DetectorServer(sendPort);
    receivePort.listen((message) async {
      final _Command command = message as _Command;
      await server._handleCommand(command);
    });
    // receivePort.sendPort - used by UI isolate to send commands to the service receiverPort
    sendPort.send(_Command(_Codes.init, args: [receivePort.sendPort]));
  }

  /// Handle the [command] received from the [ReceivePort].
  Future<void> _handleCommand(_Command command) async {
    switch (command.code) {
      case _Codes.init:
        // ----------------------------------------------------------------------
        // The [RootIsolateToken] is required for
        // [BackgroundIsolateBinaryMessenger.ensureInitialized] and must be
        // obtained on the root isolate and passed into the background isolate via
        // a [SendPort].
        // ----------------------------------------------------------------------
        RootIsolateToken rootIsolateToken =
            command.args?[0] as RootIsolateToken;
        // ----------------------------------------------------------------------
        // [BackgroundIsolateBinaryMessenger.ensureInitialized] for each
        // background isolate that will use plugins. This sets up the
        // [BinaryMessenger] that the Platform Channels will communicate with on
        // the background isolate.
        // ----------------------------------------------------------------------
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        _interpreter = Interpreter.fromAddress(command.args?[1] as int);
        inputShape = _interpreter!.getInputTensor(0).shape;
        outputShape = _interpreter!.getOutputTensor(0).shape;
        _sendPort.send(const _Command(_Codes.ready));
      case _Codes.detect:
        _sendPort.send(const _Command(_Codes.busy));
        _convertAnalysisImage(command.args?[0] as AnalysisImage);
      default:
        debugPrint('_DetectorService unrecognized command ${command.code}');
    }
  }

  void _convertAnalysisImage(AnalysisImage cameraImage) {
    var preConversionTime = DateTime.now().millisecondsSinceEpoch;

    ImageUtils.convertToImage(image: cameraImage).then((image) {
      if (image != null) {
        if (Platform.isAndroid) {
          image = img.copyRotate(image, angle: 90);
        }

        final results = analyseImage(image, preConversionTime);
        _sendPort.send(_Command(_Codes.result, args: [results]));
      }
    });
  }

  MlProcessingResult analyseImage(
    img.Image image,
    int preConversionTime,
  ) {
    var conversionElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    /// Pre-process the image
    /// Resizing image for model
    final imageInput = img.copyResize(
      image,
      width: inputShape[1],
      height: inputShape[2],
      interpolation: img.Interpolation.linear,
    );

    // Creating matrix representation from shape
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b].map((e) => e / 255.0).toList();
        },
      ),
    );

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    final result = _runInference(
      imageHeight: image.height,
      imageWidth: image.width,
      imageMatrix: imageMatrix,
    );

    final iou = NmsUtils.nmsForSingleClass(
      result,
      targetClassId: 0,
    );

    print(iou);

    var inferenceElapsedTime =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    var totalElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;
    final stats = MlProcessingStats(
      conversionTime: conversionElapsedTime,
      preProcessingTime: preProcessElapsedTime,
      inferenceTime: inferenceElapsedTime,
      totalElapsedTime: totalElapsedTime,
    );

    return MlProcessingResult(
      recognitions: iou,
      stats: stats,
    );
  }

  List<Recognition> _decodeOutput({
    required List output,
    required int imageWidth,
    required int imageHeight,
  }) {
    List<Recognition> recognitions = [];

    // Access the first batch (since output is batched)
    final detections = output[0] as List<List<num>>;

    for (var detection in detections) {
      final recognition = Recognition.fromFlatOutput(
        output: detection.map((e) => e.toDouble()).toList(),
        imageHeight: imageHeight,
        imageWidth: imageWidth,
      );

      // Create a Recognition object
      if (recognition.score > 0.6) recognitions.add(recognition);
    }

    return recognitions;
  }

  /// Object detection main function
  List<Recognition> _runInference({
    required List<List<List<num>>> imageMatrix,
    required int imageWidth,
    required int imageHeight,
  }) {
    final input = [imageMatrix];
    final listLength = outputShape.reduce((a, b) => a * b);
    final output = List.filled(listLength, 0).reshape(outputShape);
    _interpreter!.run(input, output);
    return _decodeOutput(
      output: output,
      imageHeight: imageHeight,
      imageWidth: imageWidth,
    );
  }
}
