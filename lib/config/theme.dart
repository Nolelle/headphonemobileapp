import 'package:flutter/material.dart';

// Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromRGBO(133, 86, 169, 1.00),
  scaffoldBackgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
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
    elevation: 4.0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromRGBO(133, 86, 169, 1.00),
    selectedItemColor: Colors.white,
    unselectedItemColor: Color.fromRGBO(82, 56, 110, 1.0),
    elevation: 8.0,
    type: BottomNavigationBarType.fixed,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
    bodyLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.black),
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color.fromRGBO(133, 86, 169, 1.00),
  scaffoldBackgroundColor: const Color.fromRGBO(52, 44, 72, 1.0),
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromRGBO(133, 86, 169, 1.00),
    primary: const Color.fromRGBO(133, 86, 169, 1.00),
    secondary: const Color.fromRGBO(93, 59, 129, 1.00),
    surface: const Color.fromRGBO(64, 54, 87, 1.0),
    background: const Color.fromRGBO(52, 44, 72, 1.0),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
    thumbColor: const Color.fromRGBO(133, 86, 169, 1.00),
    inactiveTrackColor: Colors.grey[700],
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
      return Colors.grey[700]!;
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
    backgroundColor: Color.fromRGBO(93, 59, 129, 1.00),
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 4.0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color.fromRGBO(93, 59, 129, 1.00),
    selectedItemColor: Colors.white,
    unselectedItemColor: Color.fromRGBO(180, 160, 200, 1.0),
    elevation: 8.0,
    type: BottomNavigationBarType.fixed,
  ),
  cardTheme: CardTheme(
    color: const Color.fromRGBO(64, 54, 87, 1.0),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    bodyLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
  ),
);
