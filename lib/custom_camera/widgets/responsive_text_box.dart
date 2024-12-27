import 'package:flutter/material.dart';

class ResponsiveTextBox extends StatelessWidget {
  const ResponsiveTextBox(
      {super.key,
      this.orientation = Orientation.portrait,
      required this.text,
      required this.landscapePadding,
      required this.portraitPadding,
      this.landscapeAlignment = Alignment.topLeft});

  final Orientation orientation;
  final String text;
  final EdgeInsetsGeometry landscapePadding;
  final EdgeInsetsGeometry portraitPadding;
  final Alignment landscapeAlignment;

  @override
  Widget build(BuildContext context) {
    if (orientation == Orientation.portrait) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: portraitPadding,
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    return Align(
        alignment: landscapeAlignment,
        child: RotatedBox(
          quarterTurns: 1,
          child: Padding(
            padding: landscapePadding,
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ));
  }
}
