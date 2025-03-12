import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/bluetooth/providers/bluetooth_provider.dart';
import 'features/presets/providers/preset_provider.dart';
import 'features/sound_test/providers/sound_test_provider.dart';
import 'features/sound_test/repositories/sound_test_repository.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/settings/providers/language_provider.dart';
import 'core/app.dart';
import 'features/presets/models/preset.dart';
import 'features/presets/repositories/preset_repository.dart';
import 'l10n/app_localizations.dart';

// Create lifecycle observer to detect when app comes to foreground
class BluetoothLifecycleObserver extends WidgetsBindingObserver {
  final BluetoothProvider bluetoothProvider;

  BluetoothLifecycleObserver(this.bluetoothProvider);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - check Bluetooth connections
      print("App resumed - checking Bluetooth connections");

      // Load saved state then check actual connections
      bluetoothProvider.loadConnectionState().then((_) {
        bluetoothProvider.checkBluetoothConnection();

        // Force audio routing if a device is connected
        if (bluetoothProvider.isDeviceConnected) {
          bluetoothProvider.forceAudioRouting();
        }
      });
    } else if (state == AppLifecycleState.paused) {
      // App going to background - save current state
      print("App paused - saving connection state");
      bluetoothProvider.saveConnectionState();
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

  // Create sound test repository and provider
  final soundTestRepository = SoundTestRepository();
  final soundTestProvider = SoundTestProvider(soundTestRepository);
  await soundTestProvider.fetchSoundTests();

  // Create theme provider
  final themeProvider = ThemeProvider();

  // Create language provider
  final languageProvider = LanguageProvider();
  await languageProvider.loadLanguage();

  // Create provider first so we can use it for the observer
  final bluetoothProvider =
      BluetoothProvider(isEmulatorTestMode: isEmulatorMode);

  // Register lifecycle observer
  final observer = BluetoothLifecycleObserver(bluetoothProvider);
  WidgetsBinding.instance.addObserver(observer);

  // Start the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => bluetoothProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => presetProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => soundTestProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => themeProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => languageProvider,
        ),
      ],
      child: MyApp(presetData: presetProvider.presets.values.toList()),
    ),
  );

  // Add a multiple-phase connection detection approach
  // This helps catch devices connected before app launch

  // Phase 1: Immediate check after app launch (already in BluetoothProvider._init())

  // Phase 2: Short delay check (helps when system is still initializing Bluetooth services)
  Future.delayed(const Duration(seconds: 2), () {
    print("Phase 2 Bluetooth connection check");
    bluetoothProvider.checkBluetoothConnection();
  });

  // Phase 3: Longer delay check (final attempt for slow-connecting devices)
  Future.delayed(const Duration(seconds: 5), () {
    print("Phase 3 Bluetooth connection check");
    bluetoothProvider.checkBluetoothConnection();

    // If connected, force audio routing to ensure proper setup
    if (bluetoothProvider.isDeviceConnected) {
      print("Connected device found, forcing audio routing");
      bluetoothProvider.forceAudioRouting();
    }
  });
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
