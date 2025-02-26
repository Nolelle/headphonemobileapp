import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/bluetooth/providers/bluetooth_provider.dart';
import 'features/presets/providers/preset_provider.dart';
import 'core/app.dart';
import 'features/presets/models/preset.dart';
import 'features/presets/repositories/preset_repository.dart';

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

  // Determine if running on emulator (simplified approach)
  final bool isEmulatorMode = await _isEmulator();

  // Create repository and provider
  final presetRepository = PresetRepository();
  final presetProvider = PresetProvider(presetRepository);
  await presetProvider.loadPresets();

  // Create provider first so we can use it for the observer
  final bluetoothProvider =
      BluetoothProvider(isEmulatorTestMode: isEmulatorMode);

  // Register lifecycle observer
  final observer = BluetoothLifecycleObserver(bluetoothProvider);
  WidgetsBinding.instance.addObserver(observer);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => bluetoothProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => presetProvider,
        ),
      ],
      child: MyApp(presetData: presetProvider.presets.values.toList()),
    ),
  );
}

// Helper function to determine if running on emulator
Future<bool> _isEmulator() async {
  try {
    // This is a simplified approach - you might want to use a more robust method
    // like device_info_plus package for production
    final String androidModel =
        await const MethodChannel('com.headphonemobileapp/settings')
                .invokeMethod('getDeviceModel') ??
            '';
    return androidModel.toLowerCase().contains('emulator') ||
        androidModel.toLowerCase().contains('sdk');
  } catch (e) {
    print('Error checking emulator status: $e');
    return false;
  }
}
