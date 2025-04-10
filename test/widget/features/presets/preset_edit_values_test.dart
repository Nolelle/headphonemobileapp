import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/views/screens/preset_page.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/l10n/app_localizations.dart';

// Mock classes
class MockPresetProvider extends Mock implements PresetProvider {
  final Map<String, Preset> _presets = {};
  bool updatePresetCalled = false;
  Preset? lastUpdatedPreset;

  @override
  Map<String, Preset> get presets => _presets;

  @override
  Preset? getPresetById(String id) {
    return _presets[id];
  }

  @override
  Future<void> updatePreset(Preset preset) async {
    updatePresetCalled = true;
    lastUpdatedPreset = preset;
    _presets[preset.id] = preset;
    return Future.value();
  }

  @override
  void setActivePreset(String id) {
    // Mock implementation
  }

  @override
  Future<bool> sendCombinedDataToDevice(
      SoundTestProvider soundTestProvider) async {
    // Mock implementation
    return Future.value(true);
  }
}

// Mock BluetoothProvider
class MockBluetoothProvider extends Mock implements BluetoothProvider {
  @override
  bool get isDeviceConnected => false;
}

// Mock SoundTestProvider
class MockSoundTestProvider extends Mock implements SoundTestProvider {
  @override
  SoundTest? get activeSoundTest => null;
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

  group('PM-005: PresetPage Edit Values Tests', () {
    late MockPresetProvider mockProvider;
    late MockBluetoothProvider mockBluetoothProvider;
    late MockSoundTestProvider mockSoundTestProvider;
    const String testPresetId = 'preset1';
    const String testPresetName = 'Test Preset';

    setUp(() {
      mockProvider = MockPresetProvider();
      mockBluetoothProvider = MockBluetoothProvider();
      mockSoundTestProvider = MockSoundTestProvider();
      mockProvider.updatePresetCalled = false;
      mockProvider.lastUpdatedPreset = null;

      // Add a test preset
      final testPreset = Preset(
        id: testPresetId,
        name: testPresetName,
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 0.0,
          'db_valueSB_BS': 0.0,
          'reduce_background_noise': false,
        },
      );

      mockProvider._presets[testPresetId] = testPreset;
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: [
          MockLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<PresetProvider>.value(value: mockProvider),
            ChangeNotifierProvider<BluetoothProvider>.value(
                value: mockBluetoothProvider),
            ChangeNotifierProvider<SoundTestProvider>.value(
                value: mockSoundTestProvider),
          ],
          child: PresetPage(
            presetId: testPresetId,
            presetName: testPresetName,
            presetProvider: mockProvider,
          ),
        ),
      );
    }

    testWidgets('should adjust slider and update preset values',
        (WidgetTester tester) async {
      // Set up a fixed size for the test
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Edit Preset'), findsOneWidget);

      // Find the first slider (overall volume)
      final sliderFinder = find.byType(Slider).first;
      expect(sliderFinder, findsOneWidget);

      // Drag the slider to change its value
      await tester.drag(sliderFinder, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Wait for debounce timer
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the updatePreset method was called
      expect(mockProvider.updatePresetCalled, isTrue);
      expect(mockProvider.lastUpdatedPreset, isNotNull);

      // Verify the value was updated (the exact value may depend on implementation)
      expect(
          mockProvider.lastUpdatedPreset!.presetData['db_valueOV'], isNot(0.0));
    });

    testWidgets('should toggle switch and update preset settings',
        (WidgetTester tester) async {
      // Set up a fixed size for the test
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the first switch (reduce background noise)
      final switchFinder = find.byType(Switch).first;
      expect(switchFinder, findsOneWidget);

      // Get the initial state of the switch
      final Switch switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, isFalse); // Should initially be false

      // Tap the switch to toggle it
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Wait for debounce timer
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the updatePreset method was called
      expect(mockProvider.updatePresetCalled, isTrue);
      expect(mockProvider.lastUpdatedPreset, isNotNull);

      // Verify the toggle value was updated
      expect(
          mockProvider.lastUpdatedPreset!.presetData['reduce_background_noise'],
          isTrue);
    });

    testWidgets('should update both sliders and toggles in the same preset',
        (WidgetTester tester) async {
      // Set up a fixed size for the test
      tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Build the widget
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // First adjust a slider
      final sliderFinder = find.byType(Slider).first;
      await tester.drag(sliderFinder, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      // Reset the update tracker
      mockProvider.updatePresetCalled = false;
      mockProvider.lastUpdatedPreset = null;

      // Then toggle a switch
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the updatePreset method was called again
      expect(mockProvider.updatePresetCalled, isTrue);
      expect(mockProvider.lastUpdatedPreset, isNotNull);

      // The preset should now have both changes
      final updatedPreset = mockProvider.lastUpdatedPreset!;
      expect(updatedPreset.presetData['db_valueOV'], isNot(0.0));
      expect(updatedPreset.presetData['reduce_background_noise'], isTrue);
    });
  });
}
