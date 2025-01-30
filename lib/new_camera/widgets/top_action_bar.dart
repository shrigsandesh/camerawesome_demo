import 'package:flutter/material.dart';

class TopActionBar extends StatelessWidget {
  const TopActionBar({super.key, this.recordingTime});
  final String? recordingTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.flash_auto,
              color: Colors.white,
            ),
          ),
          if (recordingTime != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(recordingTime!),
              ),
            ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
