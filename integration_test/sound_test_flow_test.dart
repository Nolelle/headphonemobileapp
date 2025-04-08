import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:projects/core/app.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sound Test Flow Integration Tests', () {
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

    testWidgets('Complete sound test flow', (WidgetTester tester) async {
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

      // Navigate to Sound Test tab using a more reliable finder
      final soundTestTabFinder = find.text('Sound Test');
      expect(soundTestTabFinder, findsWidgets,
          reason: 'Sound Test tab should be visible');
      await tester.tap(soundTestTabFinder.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Debug - print all text widgets to help identify UI structure
      print('Available widgets:');
      find.byType(Text).evaluate().forEach((element) {
        final widget = element.widget as Text;
        print('- Text: "${widget.data}"');
      });

      // Try to find the start button with different possible texts
      final startButtonFinder = find.text('Start New Test');
      if (startButtonFinder.evaluate().isEmpty) {
        print('Could not find "Start New Test" button, trying alternatives...');
        // Try alternative button texts
        final alternatives = ['Start Test', 'New Test', 'Begin Test'];
        for (final text in alternatives) {
          final finder = find.text(text);
          if (finder.evaluate().isNotEmpty) {
            print('Found alternative button: $text');
            await tester.tap(finder.first);
            await tester.pumpAndSettle();
            break;
          }
        }
      } else {
        // Start a new sound test
        await tester.tap(startButtonFinder);
        await tester.pumpAndSettle();
      }

      // Complete the test steps (simplified for testing)
      // Use more specific finder for buttons that might appear multiple times
      await tester.tap(find.text('Next').last);
      await tester.pumpAndSettle();

      // Test frequency responses (simplified)
      for (int i = 0; i < 3; i++) {
        // Rate the sound (use more specific finders if needed)
        await tester.tap(find.text('Good').first);
        await tester.pumpAndSettle();

        // Continue to next or finish
        if (i < 2) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        } else {
          await tester.tap(find.text('Finish'));
          await tester.pumpAndSettle();
        }
      }

      // Verify test results are displayed
      expect(find.text('Test Results'), findsOneWidget);

      // Save the test results
      await tester.tap(find.text('Save Results'));
      await tester.pumpAndSettle();

      // Verify we return to the test list
      expect(find.text('Sound Tests'), findsOneWidget);
    });
  });
}
