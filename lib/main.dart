import 'package:flutter/material.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/features/bluetooth/views/widgets/bluetooth_wrapper.dart';
import 'package:provider/provider.dart';
import 'core/app.dart';
import 'core/utils/json_loader.dart';
import 'features/bluetooth/services/bluetooth_service.dart';

// Create lifecycle observer to detect when app comes to foreground
class BluetoothLifecycleObserver extends WidgetsBindingObserver {
  final BluetoothProvider bluetoothProvider;

  BluetoothLifecycleObserver(this.bluetoothProvider);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - check Bluetooth connections
      print("App resumed - checking Bluetooth connections");
      bluetoothProvider.checkBluetoothConnection();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final presetData = await loadJson();

  // Create provider first so we can use it for the observer
  final bluetoothProvider =
      BluetoothProvider(bluetoothService: MyBluetoothService());

  // Register lifecycle observer
  final observer = BluetoothLifecycleObserver(bluetoothProvider);
  WidgetsBinding.instance.addObserver(observer);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: bluetoothProvider),
        // Other providers...
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
