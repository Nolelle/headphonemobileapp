import 'package:flutter/material.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/features/bluetooth/views/widgets/bluetooth_wrapper.dart';
import 'package:provider/provider.dart';
import 'core/app.dart';
import 'core/utils/json_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final presetData = await loadJson();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        // Add other providers here if needed
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: const Color.fromRGBO(133, 86, 169, 1.00),
          scaffoldBackgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
        ),
        home: BluetoothWrapper(
          child: MyApp(presetData: presetData),
        ),
      ),
    ),
  );
}
