import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome_demo/home.dart';

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
      home: HomePage(),
    );
  }
}
