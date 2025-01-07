import 'package:flutter/material.dart';
import '../features/main_page/main_page.dart';

class MyApp extends StatelessWidget {
  final Map<String, dynamic> presetData; // This holds the JSON data

  const MyApp(
      {super.key, required this.presetData}); // Constructor for presetData

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(presetData: presetData), // Pass the presetData directly
    );
  }
}
