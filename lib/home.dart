import 'package:camerawesome_demo/custom_camera/camera_page.dart';
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
            onPressed: () async {
              final hasSavePermission =
                  await PermissionService.requestMediaPermissions();
              if (hasSavePermission && context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CameraPage(),
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
