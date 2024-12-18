import 'dart:async';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/utlils/input_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerCameraPage extends StatefulWidget {
  const BarcodeScannerCameraPage({super.key});

  @override
  State<BarcodeScannerCameraPage> createState() =>
      _BarcodeScannerCameraPageState();
}

class _BarcodeScannerCameraPageState extends State<BarcodeScannerCameraPage> {
  final _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

  final _buffer = <String>[];
  final _barcodesNotifier = ValueNotifier<List<String>>([]);
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _barcodesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.previewOnly(
        onImageForAnalysis: (img) => _processImageBarcode(img),
        imageAnalysisConfig: AnalysisConfig(
          androidOptions: const AndroidAnalysisOptions.nv21(
            width: 1024,
          ),
          maxFramesPerSecond: 5,
          autoStart: false,
        ),
        builder: (cameraModeState, preview) {
          return _BarcodeDisplayWidget(
            barcodesNotifier: _barcodesNotifier,
            scrollController: _scrollController,
            analysisController: cameraModeState.analysisController!,
          );
        },
      ),
    );
  }

  Future _processImageBarcode(AnalysisImage img) async {
    final inputImage = img.toInputImage();

    try {
      var recognizedBarCodes = await _barcodeScanner.processImage(inputImage);
      for (Barcode barcode in recognizedBarCodes) {
        debugPrint("Barcode: [${barcode.format}]: ${barcode.rawValue}");
        _addBarcode("[${barcode.format.name}]: ${barcode.rawValue}");
      }
    } catch (error) {
      debugPrint("...sending image resulted error $error");
    }
  }

  void _addBarcode(String value) {
    try {
      if (_buffer.length > 300) {
        _buffer.removeRange(_buffer.length - 300, _buffer.length);
      }
      if (_buffer.isEmpty || value != _buffer[0]) {
        _buffer.insert(0, value);
        _barcodesNotifier.value = List.from(_buffer); // Notify listeners
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastLinearToSlowEaseIn,
        );
      }
    } catch (err) {
      debugPrint("...logging error $err");
    }
  }
}

class _BarcodeDisplayWidget extends StatefulWidget {
  final ValueNotifier<List<String>> barcodesNotifier;
  final ScrollController scrollController;

  final AnalysisController analysisController;

  const _BarcodeDisplayWidget({
    required this.barcodesNotifier,
    required this.scrollController,
    required this.analysisController,
  });

  @override
  State<_BarcodeDisplayWidget> createState() => _BarcodeDisplayWidgetState();
}

class _BarcodeDisplayWidgetState extends State<_BarcodeDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.tealAccent.withOpacity(0.7),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              value: widget.analysisController.enabled,
              onChanged: (newValue) async {
                if (widget.analysisController.enabled == true) {
                  await widget.analysisController.stop();
                } else {
                  await widget.analysisController.start();
                }
                setState(() {});
              },
              title: const Text(
                "Enable barcode scan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ValueListenableBuilder<List<String>>(
              valueListenable: widget.barcodesNotifier,
              builder: (context, value, child) => value.isEmpty
                  ? const SizedBox.expand()
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 8),
                      controller: widget.scrollController,
                      itemCount: value.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      itemBuilder: (context, index) => Text(value[index]),
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}
