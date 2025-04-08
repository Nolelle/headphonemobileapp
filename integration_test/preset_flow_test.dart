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

      // Tap the ElevatedButton associated with the preset to activate it
      // Assuming the button text is the preset name for finding purposes
      final presetButtonFinder =
          find.widgetWithText(ElevatedButton, 'Integration Test Preset');
      expect(presetButtonFinder, findsOneWidget,
          reason: 'Preset button should be visible');
      await tester.tap(presetButtonFinder);
      await tester.pumpAndSettle();

      // Now, tap the 'Edit' button that should appear
      final editButtonFinder = find.text('Edit');
      expect(editButtonFinder, findsOneWidget,
          reason: 'Edit button should appear after activating preset');
      await tester.tap(editButtonFinder);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify navigation happened by checking for PresetPage AppBar title
      // Assuming the title is 'Edit Preset' or similar
      expect(find.widgetWithText(AppBar, 'Edit Preset'), findsOneWidget,
          reason: 'Should navigate to PresetPage with correct title');

      // Debug: Print widgets on the PresetPage
      print('Widgets on PresetPage after tapping Edit:'); // Updated log message
      find.byType(Widget).evaluate().forEach((element) {
        print('- ${element.widget.runtimeType}');
        if (element.widget is Text) {
          print('  - Text: "${(element.widget as Text).data}"');
        } else if (element.widget is TextFormField) {
          print('  - TextFormField found!');
        }
      });

      // Change the preset name on the PresetPage
      // Try finding any TextFormField, not just the first, in case of structure changes
      final nameFieldFinder = find.byType(TextFormField);
      expect(nameFieldFinder, findsOneWidget, // Check for at least one
          reason:
              'Preset name field (TextFormField) should be present on PresetPage');
      await tester.tap(nameFieldFinder.first); // Tap the first one found
      await tester.pumpAndSettle(); // Add pump after tap
      await tester.enterText(nameFieldFinder.first, 'Updated Preset Name');

      // Save the changes (assuming 'Save' button exists on PresetPage)
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Expect to be back on the preset list automatically or navigate back
      // If not automatic, add tester.pageBack();
      // Let's assume it navigates back automatically after save for now.
      await tester.pumpAndSettle();

      // Verify the updated name appears on the list page
      expect(find.text('Updated Preset Name'), findsOneWidget);

      // --- Rest of the delete flow ---
      // Activate the updated preset again
      final updatedPresetButtonFinder =
          find.widgetWithText(ElevatedButton, 'Updated Preset Name');
      expect(updatedPresetButtonFinder, findsOneWidget,
          reason: 'Updated preset button should be visible');
      await tester.tap(updatedPresetButtonFinder);
      await tester.pumpAndSettle();

      // Tap the delete button
      final deleteButtonFinder = find.text('Delete');
      expect(deleteButtonFinder, findsOneWidget,
          reason: 'Delete button should appear');
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();

      // Confirm deletion in the dialog
      await tester
          .tap(find.text('Yes')); // Assuming confirmation dialog uses "Yes"
      await tester.pumpAndSettle();

      // Verify preset is gone
      expect(find.text('Updated Preset Name'), findsNothing);
    });
  });
}
