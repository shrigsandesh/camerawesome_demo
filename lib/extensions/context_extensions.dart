import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  TextStyle get headlineMedium =>
      Theme.of(this).textTheme.headlineMedium!.copyWith(
            color: const Color(0xffF5F5F5),
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            height: (28.0 / 18.0),
            fontFamily: 'Roboto',
          );
}
