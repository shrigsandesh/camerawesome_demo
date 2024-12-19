import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class DefaultCameraAswesomeUI extends StatelessWidget {
  const DefaultCameraAswesomeUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        saveConfig: SaveConfig.photoAndVideo(),
        defaultFilter: AwesomeFilter.vintage,
      ),
    );
  }
}
