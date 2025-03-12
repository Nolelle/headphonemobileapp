import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/views/screens/preset_page.dart';
import 'package:projects/l10n/app_localizations.dart';

// Mock classes
class MockPresetProvider extends Mock implements PresetProvider {
  final Map<String, Preset> _presets = {};

  @override
  Map<String, Preset> get presets => _presets;

  @override
  Future<void> updatePreset(Preset preset) async {
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

Widget createTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: [
      MockLocalizationsDelegate(),
    ],
    home: child,
  );
}

void main() {
  group('PresetPage Notification Tests', () {
    late MockPresetProvider presetProvider;
    const String testPresetId = 'test-preset-1';
    const String testPresetName = 'Test Preset';

    setUp(() {
      presetProvider = MockPresetProvider();

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

    testWidgets('should show notification when slider value changes',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<PresetProvider>.value(
          value: presetProvider,
          child: createTestableWidget(
            PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - change a slider value
      final Finder overallVolumeSlider = find.byType(Slider).first;
      await tester.drag(overallVolumeSlider, const Offset(20.0, 0.0));
      await tester.pumpAndSettle();

      // Assert - should show "Updating..." notification
      expect(find.text('Updating Overall Volume...'), findsOneWidget);

      // Wait for the debounce timer
      await tester.pump(const Duration(milliseconds: 600));

      // Assert - should show "Updated" notification
      expect(find.text('Overall Volume Updated'), findsOneWidget);
    });

    testWidgets('should show notification when switch is toggled',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<PresetProvider>.value(
          value: presetProvider,
          child: createTestableWidget(
            PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - toggle a switch
      final Finder backgroundNoiseSwitch = find.byType(Switch).first;
      await tester.tap(backgroundNoiseSwitch);
      await tester.pumpAndSettle();

      // Assert - should show "Updating..." notification
      expect(find.text('Updating Reduce Background Noise...'), findsOneWidget);

      // Wait for the debounce timer
      await tester.pump(const Duration(milliseconds: 600));

      // Assert - should show "Updated" notification
      expect(find.text('Reduce Background Noise Updated'), findsOneWidget);
    });

    testWidgets('should show notification when preset name is changed',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<PresetProvider>.value(
          value: presetProvider,
          child: createTestableWidget(
            PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - change the preset name
      final Finder nameField = find.byType(TextField).first;
      await tester.tap(nameField);
      await tester.enterText(nameField, 'New Preset Name');

      // Unfocus the text field to trigger save
      await tester.tap(find.text('Edit Preset'));
      await tester.pumpAndSettle();

      // Assert - should show "Updating..." notification
      expect(find.text('Updating Preset Name...'), findsOneWidget);

      // Wait for the debounce timer
      await tester.pump(const Duration(milliseconds: 600));

      // Assert - should show "Updated" notification
      expect(find.text('Preset Name Updated'), findsOneWidget);
    });

    testWidgets(
        'should show notification when back button is pressed with changes',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<PresetProvider>.value(
          value: presetProvider,
          child: createTestableWidget(
            PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - change a slider value
      final Finder overallVolumeSlider = find.byType(Slider).first;
      await tester.drag(overallVolumeSlider, const Offset(20.0, 0.0));
      await tester.pumpAndSettle();

      // Wait for the debounce timer and notification to disappear
      await tester.pump(const Duration(seconds: 2));

      // Press back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert - should show "Successfully Updated" notification
      expect(find.text('Test Preset Successfully Updated'), findsOneWidget);
    });

    testWidgets(
        'should not show notification when back button is pressed without changes',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ChangeNotifierProvider<PresetProvider>.value(
          value: presetProvider,
          child: createTestableWidget(
            PresetPage(
              presetId: testPresetId,
              presetName: testPresetName,
              presetProvider: presetProvider,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - press back button without making changes
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert - should not show any notification
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
