import 'package:camerawesome_demo/barcode_scanner.dart';
import 'package:camerawesome_demo/custom_ui.dart';
import 'package:camerawesome_demo/default_ui.dart';
import 'package:camerawesome_demo/services/permission_service.dart';
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
            onPressed: () async {
              final hasSavePermission =
                  await PermissionService.requestMediaPermissions();
              if (hasSavePermission && context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomCameraUi(),
                  ),
                );
              }
            },
            child: const Text("custom camera"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DefaultCameraAswesomeUI(),
                ),
              );
            },
            child: const Text("Default camera"),
          ),
        ],
      ),
    );
  }
}
