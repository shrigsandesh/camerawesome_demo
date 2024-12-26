import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  TextStyle get headlineMedium =>
      Theme.of(this).textTheme.headlineMedium!.copyWith(
            color: const Color(0xffF5F5F5), //headline text color
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
            height: (28.0 / 18.0),
            fontFamily: 'Roboto',
          );
  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!.copyWith(
        color: const Color(0xffF5F5F5), //headline text color
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        height: (24.0 / 16.0),
        letterSpacing: 0.15,
        fontFamily: 'Roboto',
      );
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!.copyWith(
        color: const Color(0xffD1D2D3), //subtext color
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: (20.0 / 14.0),
        letterSpacing: 0.25,
        fontFamily: 'Roboto',
      );
}
