/*
 * IMPORTANT: This test is for a feature that has not yet been implemented.
 * This test will fail until the following functionality is added to the app:
 * 
 * 1. A button or option to create a preset from a sound test result
 * 2. Implementation of mapping sound test frequency results to preset settings
 * 3. A form for entering preset name when creating from sound test
 * 
 * The test serves as a specification for how the feature should work when implemented.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';
import 'package:projects/features/sound_test/views/screens/sound_test_page.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/core/app.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock method channels
  setupMockMethodChannels();

  group('Sound Test to Preset Integration Tests (IN-003)', () {
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

      // Initialize BluetoothProvider in test mode
      bluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);
    });

    // Helper function to create a sound test with predetermined results
    Future<SoundTest> createTestSoundTest() async {
      final soundTestId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      final soundTest = SoundTest(
        id: soundTestId,
        name: 'Test Sound Profile',
        dateCreated: DateTime.now(),
        soundTestData: {
          'L_user_250Hz_dB': 5.0,
          'L_user_500Hz_dB': 3.0,
          'L_user_1000Hz_dB': 2.0,
          'L_user_2000Hz_dB': 4.0,
          'L_user_4000Hz_dB': 6.0,
          'L_user_8000Hz_dB': 8.0,
          'R_user_250Hz_dB': 4.0,
          'R_user_500Hz_dB': 2.0,
          'R_user_1000Hz_dB': 1.0,
          'R_user_2000Hz_dB': 3.0,
          'R_user_4000Hz_dB': 5.0,
          'R_user_8000Hz_dB': 7.0,
        },
        icon: Icons.hearing,
      );

      await soundTestProvider.createSoundTest(soundTest);
      return soundTest;
    }

    testWidgets('Create preset from sound test results',
        (WidgetTester tester) async {
      // Create a test sound test with predetermined results
      final soundTest = await createTestSoundTest();
      soundTestProvider.setActiveSoundTest(soundTest.id);

      // Build the main app widget
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
          child: MyApp(presetData: presetProvider.presets.values.toList()),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to sound test page with a more reliable approach
      final soundTestTab = find.text('Sound Test');
      expect(soundTestTab, findsWidgets,
          reason: 'Sound Test tab should be visible');
      await tester.tap(soundTestTab.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Debug - print all visible text widgets
      print('Available widgets on Sound Test page:');
      find.byType(Text).evaluate().forEach((element) {
        final widget = element.widget as Text;
        print('- Text: "${widget.data}"');
      });

      // If SoundTestPage isn't directly available, verify by page title or content
      expect(find.textContaining('Sound Test'), findsWidgets);

      // Look for the test profile with more flexibility
      final testProfileFinder = find.text('Test Sound Profile');
      if (testProfileFinder.evaluate().isEmpty) {
        print('Cannot find "Test Sound Profile", looking for alternatives...');

        // Try alternative approaches to find the test result
        final alternatives = [
          find.textContaining('Test Sound'),
          find.textContaining('Test Profile'),
          find.textContaining('Sound Profile')
        ];

        for (final finder in alternatives) {
          if (finder.evaluate().isNotEmpty) {
            print(
                'Found alternative: ${(finder.evaluate().first.widget as Text).data}');
            await tester.tap(finder.first);
            await tester.pumpAndSettle();
            break;
          }
        }
      } else {
        await tester.tap(testProfileFinder);
        await tester.pumpAndSettle();
      }

      // Looking for a "Create Preset" or similar button to tap
      print('Looking for preset creation button...');

      // Print all buttons
      print('Available buttons:');
      find.byType(ElevatedButton).evaluate().forEach((element) {
        final buttonWidget = element.widget as ElevatedButton;
        if (buttonWidget.child is Text) {
          print('- Button: "${(buttonWidget.child as Text).data}"');
        } else {
          print(
              '- Button with non-text child: ${buttonWidget.child.runtimeType}');
        }
      });

      // Try different buttons that might be for creating a preset
      final createPresetOptions = [
        find.text('Create Preset from Test'),
        find.text('Create Preset'),
        find.text('New Preset'),
        find.text('Use for Preset'),
        find.text('Generate Preset'),
        find.textContaining('Preset')
      ];

      bool buttonFound = false;
      for (final finder in createPresetOptions) {
        if (finder.evaluate().isNotEmpty) {
          print(
              'Found preset button: ${(finder.evaluate().first.widget as Text).data}');
          await tester.tap(finder.first);
          await tester.pumpAndSettle();
          buttonFound = true;
          break;
        }
      }

      if (!buttonFound) {
        print(
            'Could not find preset creation button. Taking screenshot of current screen.');
        // Try to tap something else that might be relevant
        final anyButton = find.byType(ElevatedButton);
        if (anyButton.evaluate().isNotEmpty) {
          print('Tapping first available button');
          await tester.tap(anyButton.first);
          await tester.pumpAndSettle();
        }
      }

      // Verify we're on a preset creation screen - it might have a form for naming the preset
      expect(find.text('New Preset from Sound Test'), findsOneWidget);

      // Enter a name for the new preset
      await tester.enterText(
          find.byType(TextField).first, 'Sound-Based Preset');
      await tester.pumpAndSettle();

      // Tap save or create button
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Navigate to presets list to verify the new preset exists
      await tester.tap(find.text('Presets'));
      await tester.pumpAndSettle();

      // Verify the preset was created with the correct name
      expect(find.text('Sound-Based Preset'), findsOneWidget);

      // Tap on the new preset to view its details
      await tester.tap(find.text('Sound-Based Preset'));
      await tester.pumpAndSettle();

      // Verify the preset contains values derived from the sound test
      // The exact verification will depend on how your app maps sound test results to preset settings

      // For example, check if the overall volume setting reflects the average hearing levels
      // This is just an example - adjust based on your actual implementation
      final overallVolumeText = find.textContaining('dB').first;
      expect(overallVolumeText, findsOneWidget);

      // Check that frequency-specific settings are properly set
      // Again, this is an example and should be adjusted based on implementation
      expect(find.text('Bass'), findsOneWidget);
      expect(find.text('Mid'), findsOneWidget);
      expect(find.text('Treble'), findsOneWidget);
    });
  });
}
