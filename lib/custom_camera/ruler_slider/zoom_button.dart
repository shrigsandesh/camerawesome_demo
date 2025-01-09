import 'package:camerawesome_demo/custom_camera/ruler_slider/constants.dart';
import 'package:camerawesome_demo/custom_camera/ruler_slider/ruler_zoom_slider_config.dart';
import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class ZoomButton extends StatelessWidget {
  const ZoomButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: RulerZoomConstants.defaultButtonSize,
        height: RulerZoomConstants.defaultButtonSize,
        margin: const EdgeInsets.symmetric(
          horizontal: RulerZoomConstants.defaultButtonMargin,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.8),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            title,
            style: context.bodyMedium.copyWith(fontSize: 12.0),
          ),
        ),
      ),
    );
  }
}
