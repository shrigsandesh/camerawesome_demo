import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class ZoomControlWidget extends StatefulWidget {
  const ZoomControlWidget({super.key, required this.state});

  final CameraState state;

  @override
  State<ZoomControlWidget> createState() => _ZoomControlWidgetState();
}

class _ZoomControlWidgetState extends State<ZoomControlWidget> {
  final List<double> zoomList = [1.0, 1.5, 2.0];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: StreamBuilder<double>(
          stream: widget.state.sensorConfig.zoom$,
          builder: (_, snapshot) {
            if (snapshot.data == null) {
              return const SizedBox.shrink();
            }
            return SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: zoomList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      widget.state.sensorConfig
                          .setZoom(normalizeZoom(zoomList[index], 1, 2));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == selectedIndex
                            ? Colors.black.withOpacity(.5)
                            : Colors.transparent,
                      ),
                      child: Center(
                          child: Text(
                        "${zoomList[index]}x",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      )),
                    ),
                  );
                },
              ),
            );
          },
        ));
  }
}

double normalizeZoom(double value, double minValue, double maxValue) {
  // Normalize the value using min-max normalization formula
  // (value - min) / (max - min)
  double normalizedValue = (value - minValue) / (maxValue - minValue);

  // Clamp the value between 0 and 1 to ensure it's in the desired range
  return normalizedValue.clamp(0.0, 1.0);
}
