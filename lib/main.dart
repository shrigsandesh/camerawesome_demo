// import 'package:better_open_file/better_open_file.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/custom_ui.dart';

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
      title: 'camerAwesome',
      home: CustomUiExample2(),
    );
  }
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: CameraAwesomeBuilder.custom(
              builder: (state, preview) {
                return Container(
                  color: Colors.red,
                );
              },
              saveConfig: SaveConfig.photoAndVideo())),
    );
  }
}
