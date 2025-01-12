import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_camera/camera_page.dart';
import 'package:camerawesome_demo/custom_camera/camera_page2.dart';
import 'package:camerawesome_demo/services/permission_service.dart';

import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CamerawesomePlugin.checkAndRequestPermissions(false).then(
    (value) {
      runApp(const CameraAwesomeApp());
    },
  );
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'camerAwesome',
      home: HomePage(),
    );
  }
}

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
            onPressed: () async {
              final hasSavePermission =
                  await PermissionService.requestMediaPermissions();
              if (hasSavePermission && context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // builder: (context) => const CameraPage(),
                    builder: (context) => const CameraPage2(),
                  ),
                );
              }
            },
            child: const Text("custom camera"),
          ),
        ],
      ),
    );
  }
}
