import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class OrientationWrapperWidget extends StatefulWidget {
  final Widget Function(BuildContext context, Orientation orientation) builder;

  const OrientationWrapperWidget({
    super.key,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() {
    return OrientationWrapperWidgetState();
  }
}

class OrientationWrapperWidgetState extends State<OrientationWrapperWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CameraOrientations>(
      stream: CamerawesomePlugin.getNativeOrientation(),
      builder: (_, orientationSnapshot) {
        final orientation = orientationSnapshot.data;
        return widget.builder(context, getOrienataion(orientation));
      },
    );
  }

  Orientation getOrienataion(CameraOrientations? orientation) {
    switch (orientation) {
      case CameraOrientations.landscape_left:
        return Orientation.landscape;
      case CameraOrientations.landscape_right:
        return Orientation.landscape;
      case CameraOrientations.portrait_up:
        return Orientation.portrait;
      case CameraOrientations.portrait_down:
        return Orientation.portrait;
      case null:
        return Orientation.portrait;
    }
  }
}
