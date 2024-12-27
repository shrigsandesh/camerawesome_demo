import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class InfoPopup extends StatelessWidget {
  const InfoPopup({super.key, required this.orientation});

  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: orientation == Orientation.portrait
          ? _body(context, Orientation.portrait)
          : RotatedBox(
              quarterTurns: 1,
              child: _body(context, Orientation.landscape),
            ),
    );
  }

  Widget _body(BuildContext context, Orientation orientation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      margin: orientation == Orientation.landscape
          ? null
          : const EdgeInsets.symmetric(horizontal: 32.0),
      decoration: BoxDecoration(
          color: const Color(0xff28282B), //major color
          borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              'assets/info_dummy.png',
              width: 136.0,
              height: 192.0,
            ),
          ),
          const SizedBox(
            width: 20.0,
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For Accurate Measurements',
                  style: context.titleMedium,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  '☑️ You should keep fish inside white boundary.',
                  style: context.bodyMedium,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Text(
                  '☑️ And PROOF BALL should be inside the yellow box.',
                  style: context.bodyMedium,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
