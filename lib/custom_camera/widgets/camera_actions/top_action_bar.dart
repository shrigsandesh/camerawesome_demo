import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';

class TopActionBar extends StatelessWidget {
  const TopActionBar({super.key, required this.state});

  final CameraState? state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (state != null)
            AwesomeFlashButton(
              state: state!,
            ),
        ],
      ),
    );
  }
}
