import 'package:flutter/material.dart';
import 'core/app.dart';
import 'core/utils/json_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final presetData = await loadJson();
  runApp(MyApp(presetData: presetData));
}
