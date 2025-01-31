import 'package:flutter/widgets.dart';

class LazyLoadWidget extends StatelessWidget {
  const LazyLoadWidget({super.key, required this.child});

  final Widget child;

  Future<void> _delayedFuture() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _delayedFuture(),
      builder: (context, snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.connectionState == ConnectionState.done ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}
