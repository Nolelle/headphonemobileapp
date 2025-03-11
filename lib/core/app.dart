import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/presets/models/preset.dart';
import '../features/bluetooth/providers/bluetooth_provider.dart';
import '../features/bluetooth/views/widgets/bluetooth_wrapper.dart';
import 'main_nav.dart';

class MyApp extends StatelessWidget {
  final List<Preset> presetData;

  const MyApp({super.key, required this.presetData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Headphone App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const BluetoothWrapper(
        child: MainNavigation(),
      ),
    );
  }
}
