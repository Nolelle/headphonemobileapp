import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/core/app.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bluetooth Connection Flow Tests (BT-004)', () {
    late PresetProvider presetProvider;
    late SoundTestProvider soundTestProvider;
    late LanguageProvider languageProvider;
    late ThemeProvider themeProvider;
    late BluetoothProvider bluetoothProvider;

    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});

      // Create providers with clean repositories
      final presetRepository = PresetRepository();
      presetProvider = PresetProvider(presetRepository);
      await presetProvider.loadPresets();

      final soundTestRepository = SoundTestRepository();
      soundTestProvider = SoundTestProvider(soundTestRepository);
      await soundTestProvider.fetchSoundTests();

      languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      themeProvider = ThemeProvider();

      // Initialize BluetoothProvider in test mode (we'll override the method channel separately)
      bluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);
    });

    testWidgets('Connect to a Bluetooth device through UI flow',
        (WidgetTester tester) async {
      // Set up custom mock method channel for Bluetooth
      const MethodChannel bluetoothChannel =
          MethodChannel('com.headphonemobileapp/bluetooth');

      // Store method call history to verify calls
      final List<MethodCall> methodCalls = [];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        bluetoothChannel,
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);

          switch (methodCall.method) {
            case 'isBluetoothEnabled':
              return true;

            case 'getScannedDevices':
              // Return a mock scanned device
              return [
                {
                  'id': 'device1',
                  'name': 'Test Device',
                  'type': 'classic',
                }
              ];

            case 'startScan':
              // Just return success
              return true;

            case 'stopScan':
              return true;

            case 'connectToDevice':
              // Return success for connection attempt
              return true;

            case 'getConnectedDevice':
              // After connecting, return the connected device
              if (methodCalls.any((call) => call.method == 'connectToDevice')) {
                return {
                  'id': 'device1',
                  'name': 'Test Device',
                  'type': 'classic',
                };
              }
              return null;

            case 'isAudioDeviceConnected':
              // Return true after connecting
              return methodCalls
                  .any((call) => call.method == 'connectToDevice');

            case 'disconnectDevice':
              return true;

            default:
              return null;
          }
        },
      );

      // Build the app with our providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PresetProvider>.value(value: presetProvider),
            ChangeNotifierProvider<SoundTestProvider>.value(
                value: soundTestProvider),
            ChangeNotifierProvider<LanguageProvider>.value(
                value: languageProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<BluetoothProvider>.value(
                value: bluetoothProvider),
          ],
          child: const MyApp(presetData: []),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      // Navigate to Bluetooth Settings
      await tester.tap(find.text('Bluetooth Settings'));
      await tester.pumpAndSettle();

      // Tap on Scan button
      await tester.tap(find.text('Scan'));
      await tester.pumpAndSettle();

      // Verify scan was started
      expect(
        methodCalls.any((call) => call.method == 'startScan'),
        isTrue,
        reason: 'startScan should have been called',
      );

      // Wait for scan results to appear
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify the test device appears in the list
      expect(find.text('Test Device'), findsOneWidget);

      // Tap on Connect button for the device
      await tester.tap(find.text('Connect').last);
      await tester.pumpAndSettle();

      // Verify connect was called
      expect(
        methodCalls.any((call) => call.method == 'connectToDevice'),
        isTrue,
        reason: 'connectToDevice should have been called',
      );

      // Verify the UI shows the device is connected
      expect(find.text('Connected: Yes'), findsOneWidget);
    });
  });
}
