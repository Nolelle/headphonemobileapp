import 'package:flutter/material.dart';
import 'core/app.dart';
import 'core/utils/json_loader.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure async code can run in main()
  final presetData = await loadJson(); // Load the JSON data asynchronously
  runApp(MyApp(presetData: presetData)); // Pass the data to the app
}
