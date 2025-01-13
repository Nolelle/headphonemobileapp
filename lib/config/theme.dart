import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: const Color.fromRGBO(133, 86, 169, 1.00),
  scaffoldBackgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(133, 86, 169, 1.00),
    primary: const Color.fromRGBO(133, 86, 169, 1.00),
    secondary: const Color.fromRGBO(93, 59, 129, 1.00),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
    thumbColor: const Color.fromRGBO(133, 86, 169, 1.00),
    inactiveTrackColor: Colors.grey[300],
    overlayColor: const Color.fromRGBO(133, 86, 169, 0.2),
  ),
  switchTheme: SwitchThemeData(
    thumbColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return Colors.white;
    }),
    trackColor:
        WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return const Color.fromRGBO(133, 86, 169, 1.00);
      }
      return Colors.grey;
    }),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromRGBO(133, 86, 169, 1.00),
    foregroundColor: Colors.white,
    centerTitle: true,
  ),
);
