import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projects/core/app.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Preset Flow Integration Tests', () {
    late PresetProvider presetProvider;
    late SoundTestProvider soundTestProvider;
    late LanguageProvider languageProvider;
    late ThemeProvider themeProvider;
    late BluetoothProvider bluetoothProvider;

    setUp(() async {
      // Set up method channels
      setupMockMethodChannels();

      // Set up shared preferences for testing
      SharedPreferences.setMockInitialValues({});

      // Initialize providers with their repositories
      final presetRepository = PresetRepository();
      presetProvider = PresetProvider(presetRepository);
      await presetProvider.loadPresets();

      final soundTestRepository = SoundTestRepository();
      soundTestProvider = SoundTestProvider(soundTestRepository);
      await soundTestProvider.fetchSoundTests();

      languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      themeProvider = ThemeProvider();

      // Initialize Bluetooth provider in test mode
      bluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);
    });

    testWidgets('Create, edit, and delete a preset',
        (WidgetTester tester) async {
      // Add test preset data
      final testPreset = Preset(
        id: 'test_preset_1',
        name: 'Integration Test Preset',
        dateCreated: DateTime.now(),
        presetData: {
          'leftVolume': 80,
          'rightVolume': 80,
          'balance': 0,
          'bassBoost': 2,
          'noiseReduction': 1,
        },
      );

      // Add the preset to the provider
      await presetProvider.createPreset(testPreset);

      // Build the app with MultiProvider
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

      // Navigate to Presets tab - use more reliable finder
      // Use ByTooltip, byIcon, or other more specific finder if text alone isn't reliable
      final presetTab = find.text('Presets');
      expect(presetTab, findsWidgets, reason: 'Presets tab should be visible');
      await tester.tap(presetTab.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify preset is in the list
      expect(find.text('Integration Test Preset'), findsOneWidget);

      // Tap on the preset to edit it
      await tester.tap(find.text('Integration Test Preset'));
      await tester.pumpAndSettle();

      // Change the preset name
      await tester.tap(find.byType(TextFormField).first);
      await tester.enterText(
          find.byType(TextFormField).first, 'Updated Preset Name');

      // Save the changes
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Return to preset list
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify the updated name appears
      expect(find.text('Updated Preset Name'), findsOneWidget);

      // Long press to bring up delete option
      await tester.longPress(find.text('Updated Preset Name'));
      await tester.pumpAndSettle();

      // Tap the delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      // Verify preset is gone
      expect(find.text('Updated Preset Name'), findsNothing);
    });
  });
}
