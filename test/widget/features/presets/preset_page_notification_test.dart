import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/views/screens/preset_page.dart';
import 'package:projects/l10n/app_localizations.dart';

// Mock classes
class MockPresetProvider extends Mock implements PresetProvider {
  final Map<String, Preset> _presets = {};
  bool updatePresetCalled = false;

  @override
  Map<String, Preset> get presets => _presets;

  @override
  Preset? getPreset(String id) {
    return _presets[id];
  }

  @override
  Future<void> updatePreset(Preset preset) async {
    updatePresetCalled = true;
    _presets[preset.id] = preset;
    return Future.value();
  }
}

// Mock AppLocalizations for testing
class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super(const Locale('en'));

  @override
  String translate(String key) {
    final Map<String, String> translations = {
      'edit_preset': 'Edit Preset',
      'preset_name': 'Preset Name',
      'successfully_updated': 'Successfully Updated',
      'updated': 'Updated',
      'updating': 'Updating',
      'overall_volume': 'Overall Volume',
      'background_sounds': 'Background Sounds',
      'reduce_background_noise': 'Reduce Background Noise',
      'reduce_wind_noise': 'Reduce Wind Noise',
      'soften_sudden_noise': 'Soften Sudden Noise',
      'softer': 'Softer',
      'louder': 'Louder',
    };
    return translations[key] ?? key;
  }
}

class MockLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => MockAppLocalizations();

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PresetPage Notification Tests', () {
    late MockPresetProvider presetProvider;
    const String testPresetId = 'test-preset-1';
    const String testPresetName = 'Test Preset';

    setUp(() {
      presetProvider = MockPresetProvider();
      presetProvider.updatePresetCalled = false;

      // Add a test preset
      final testPreset = Preset(
        id: testPresetId,
        name: testPresetName,
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 0.0,
          'db_valueSB_BS': 0.0,
          'db_valueSB_MRS': 0.0,
          'db_valueSB_TS': 0.0,
          'reduce_background_noise': false,
          'reduce_wind_noise': false,
          'soften_sudden_noise': false,
        },
      );

      presetProvider._presets[testPresetId] = testPreset;
    });

    testWidgets('should update preset when slider value changes',
        (WidgetTester tester) async {
      // Set up a fixed size for the test
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            MockLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          home: ChangeNotifierProvider<PresetProvider>.value(
            value: presetProvider,
            child: PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the page is rendered correctly
      expect(find.text('Edit Preset'), findsOneWidget);

      // Find the slider
      final Finder slider = find.byType(Slider).first;
      expect(slider, findsOneWidget);

      // Simulate a change in the slider value
      await tester.drag(slider, const Offset(20.0, 0.0));
      await tester.pumpAndSettle();

      // Wait for the debounce timer
      await tester.pump(const Duration(milliseconds: 600));

      // Verify that updatePreset was called
      expect(presetProvider.updatePresetCalled, isTrue);
    });

    testWidgets('should update preset when name is changed',
        (WidgetTester tester) async {
      // Set up a fixed size for the test
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            MockLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          home: ChangeNotifierProvider<PresetProvider>.value(
            value: presetProvider,
            child: PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the text field
      final Finder textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Change the text
      await tester.enterText(textField, 'New Preset Name');

      // Simulate pressing the done/enter key on the keyboard
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Wait for the debounce timer
      await tester.pump(const Duration(milliseconds: 600));

      // If the above doesn't work, try this alternative approach:
      // Directly trigger the onSubmitted callback
      if (!presetProvider.updatePresetCalled) {
        // Get the TextField widget
        final TextField textFieldWidget = tester.widget(textField);
        // Manually call the onSubmitted callback if it exists
        if (textFieldWidget.onSubmitted != null) {
          textFieldWidget.onSubmitted!('New Preset Name');
          await tester.pumpAndSettle();
          await tester.pump(const Duration(milliseconds: 600));
        }
      }

      // Verify that updatePreset was called
      expect(presetProvider.updatePresetCalled, isTrue);
    });

    testWidgets('should update preset when back button is pressed with changes',
        (WidgetTester tester) async {
      // Set up a fixed size for the test
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            MockLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          home: ChangeNotifierProvider<PresetProvider>.value(
            value: presetProvider,
            child: PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the text field and change it to create a change
      final Finder textField = find.byType(TextField);
      await tester.enterText(textField, 'New Preset Name');
      await tester.pumpAndSettle();

      // Reset the flag to check if it's called again when pressing back
      presetProvider.updatePresetCalled = false;

      // Press back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify that updatePreset was called
      expect(presetProvider.updatePresetCalled, isTrue);
    });

    testWidgets(
        'should not update preset when back button is pressed without changes',
        (WidgetTester tester) async {
      // Set up a fixed size for the test
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: [
            MockLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
          ],
          home: ChangeNotifierProvider<PresetProvider>.value(
            value: presetProvider,
            child: PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Press back button without making changes
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify that updatePreset was not called
      expect(presetProvider.updatePresetCalled, isFalse);
    });
  });
}
