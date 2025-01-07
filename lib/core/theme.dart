import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: const Color.fromRGBO(133, 86, 169, 1.00),
  scaffoldBackgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromRGBO(133, 86, 169, 1.00),
    titleTextStyle: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      fontSize: 16.0,
      color: Colors.black87,
    ),
  ),
);
