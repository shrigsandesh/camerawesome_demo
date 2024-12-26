import 'package:camerawesome_demo/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class InfoPopup extends StatelessWidget {
  const InfoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        margin: const EdgeInsets.symmetric(horizontal: 32.0),
        decoration: BoxDecoration(
            color: const Color(0xff28282B), //major color
            borderRadius: BorderRadius.circular(8.0)),
        child: Row(
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
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconTextRow(
                    text1: 'For Accurate',
                    text2: 'Measurements',
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  IconTextRow(
                    text1: 'You should',
                    text2: 'keep fish inside white boundary.',
                    icon: Icon(
                      Icons.check_box_rounded,
                      color: Color(0xffD1D2D3),
                      size: 18.0,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  IconTextRow(
                    text1: 'And PROOF',
                    text2: 'BALL should be inside the yellow box.',
                    icon: Icon(
                      Icons.check_box_rounded,
                      color: Color(0xffD1D2D3),
                      size: 18.0,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class IconTextRow extends StatelessWidget {
  const IconTextRow({
    super.key,
    this.icon,
    required this.text1,
    required this.text2,
  });

  final Widget? icon;
  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: icon ?? const SizedBox.shrink(),
            ),
            if (icon != null)
              const SizedBox(
                width: 2.0,
              ),
            Flexible(
              child: Text(
                text1,
                style: icon != null ? context.bodyMedium : context.titleMedium,
                //text color : sub text color,
              ),
            ),
          ],
        ),
        Text(
          text2,
          style: icon != null ? context.bodyMedium : context.titleMedium,
        )
      ],
    );
  }
}
