import 'package:camerawesome_demo/barcode_scanner.dart';
import 'package:camerawesome_demo/custom_ui.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camerawesome'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerCameraPage(),
                ),
              );
            },
            child: const Text("Barcode Scanner"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CustomCameraUi(),
                ),
              );
            },
            child: const Text("custom camera"),
          ),
        ],
      ),
    );
  }
}
