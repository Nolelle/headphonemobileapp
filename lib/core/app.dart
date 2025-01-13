import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../config/theme.dart';

class MyApp extends StatelessWidget {
  final Map<String, dynamic> presetData;

  const MyApp({super.key, required this.presetData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      initialRoute: '/', // Use initialRoute instead of home
      routes: appRoutes(presetData),
    );
  }
}
