import 'package:flutter/material.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'core/app.dart';
import 'core/utils/json_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final presetData = await loadJson();

  runApp(
      ChangeNotifierProvider(
        create: (_) => BluetoothProvider(),
        child: MyApp(presetData: presetData))
  );
}
