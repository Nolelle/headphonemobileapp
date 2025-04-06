import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/views/screens/preset_list_page.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';

// Mock classes for localization
import 'package:projects/l10n/app_localizations.dart';
import '../../../unit/mocks/mock_preset_provider.mocks.dart';

// Mock BluetoothProvider
class MockBluetoothProvider extends Mock implements BluetoothProvider {
  @override
  bool get isDeviceConnected => false;

  @override
  String get connectedDeviceName => 'MockDevice';
}

// Mock SoundTestProvider
class MockSoundTestProvider extends Mock implements SoundTestProvider {
  // Add necessary default behaviors or stubs if needed
}

// Mock AppLocalizations for testing
class MockAppLocalizations implements AppLocalizations {
  @override
  final Locale locale;

  MockAppLocalizations([this.locale = const Locale('en')]);

  @override
  Future<bool> load() async {
    return true;
  }

  @override
  String translate(String key) {
    final Map<String, String> translations = {
      'nav_presets': 'Presets',
      'no_presets': 'No presets available',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm_delete': 'Confirm Delete',
      'confirm_delete_message': 'Are you sure you want to delete',
      'deleted_successfully': 'deleted successfully!',
      'sent_to_device': 'Successfully sent to device!',
      'presets_count': 'Presets:',
      'max_presets': 'You can only have a maximum of 10 presets!',
      'cancel': 'Cancel',
    };
    return translations[key] ?? key;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock AppLocalizations delegate for testing
class MockAppLocalizationsDelegate
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

  group('PresetsListPage Widget Tests', () {
    late MockPresetProvider mockPresetProvider;
    late MockBluetoothProvider mockBluetoothProvider;
    late MockSoundTestProvider mockSoundTestProvider;

    setUp(() {
      mockPresetProvider = MockPresetProvider();
      mockBluetoothProvider = MockBluetoothProvider();
      mockSoundTestProvider = MockSoundTestProvider();
    });

    Widget createTestableWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: [
          MockAppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        home: Scaffold(
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider<PresetProvider>.value(
                value: mockPresetProvider,
              ),
              ChangeNotifierProvider<BluetoothProvider>.value(
                value: mockBluetoothProvider,
              ),
              ChangeNotifierProvider<SoundTestProvider>.value(
                value: mockSoundTestProvider,
              ),
            ],
            child: child,
          ),
        ),
      );
    }

    testWidgets('should display empty state when no presets are available',
        (WidgetTester tester) async {
      // Arrange
      when(mockPresetProvider.presets).thenReturn({});

      // Act
      await tester.pumpWidget(createTestableWidget(
        PresetsListPage(presetProvider: mockPresetProvider),
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No presets available'), findsOneWidget);
    });

    testWidgets('should display presets when available',
        (WidgetTester tester) async {
      // Arrange
      final mockPresets = {
        'preset1': Preset(
          id: 'preset1',
          name: 'Test Preset 1',
          dateCreated: DateTime(2023, 1, 1),
          presetData: {'db_valueOV': 0.0},
        ),
        'preset2': Preset(
          id: 'preset2',
          name: 'Test Preset 2',
          dateCreated: DateTime(2023, 1, 2),
          presetData: {'db_valueOV': 1.0},
        ),
      };

      when(mockPresetProvider.presets).thenReturn(mockPresets);
      when(mockPresetProvider.activePresetId).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestableWidget(
        PresetsListPage(presetProvider: mockPresetProvider),
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Preset 1'), findsOneWidget);
      expect(find.text('Test Preset 2'), findsOneWidget);
      expect(find.text('Presets: 2/10'), findsOneWidget);
    });

    testWidgets('should show edit and delete buttons when preset is active',
        (WidgetTester tester) async {
      // Arrange
      final mockPresets = {
        'preset1': Preset(
          id: 'preset1',
          name: 'Test Preset 1',
          dateCreated: DateTime(2023, 1, 1),
          presetData: {'db_valueOV': 0.0},
        ),
      };

      when(mockPresetProvider.presets).thenReturn(mockPresets);
      // Start with no active preset initially
      when(mockPresetProvider.activePresetId).thenReturn(null);
      // Mock the behavior when setActivePreset is called
      when(mockPresetProvider.setActivePreset('preset1')).thenAnswer((_) async {
        // Simulate the provider updating its state *after* being called
        when(mockPresetProvider.activePresetId).thenReturn('preset1');
        print(
            "[TEST LOG] Mock setActivePreset('preset1') called, updated provider state");
      });
      // Mock sendCombinedDataToDevice as it's called in onPressed
      when(mockPresetProvider.sendCombinedDataToDevice(any))
          .thenAnswer((_) async => true);

      // Act: Initial pump
      print('[TEST LOG] Pumping widget initially (no active preset)...');
      await tester.pumpWidget(createTestableWidget(
        PresetsListPage(presetProvider: mockPresetProvider),
      ));
      await tester.pumpAndSettle();

      // Assert: Buttons should NOT be visible yet
      print('[TEST LOG] Verifying buttons are NOT present initially...');
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);

      // Act: Tap the preset button to make it active
      print('[TEST LOG] Tapping preset \'Test Preset 1\'...');
      await tester.tap(find.text('Test Preset 1'));
      // Pump and settle to allow setState and rebuild
      print('[TEST LOG] Pumping after tap...');
      await tester.pumpAndSettle();

      // Assert: Buttons SHOULD be visible now
      print('[TEST LOG] Verifying buttons ARE present after tap...');
      expect(
          find.text('Test Preset 1'), findsOneWidget); // Preset still visible
      expect(find.text('Edit'), findsOneWidget); // Edit button now visible
      expect(find.text('Delete'), findsOneWidget); // Delete button now visible

      // Verify setActivePreset was called
      verify(mockPresetProvider.setActivePreset('preset1')).called(1);
    });

    testWidgets('should set active preset when tapped',
        (WidgetTester tester) async {
      // Arrange
      final mockPresets = {
        'preset1': Preset(
          id: 'preset1',
          name: 'Test Preset 1',
          dateCreated: DateTime(2023, 1, 1),
          presetData: {'db_valueOV': 0.0},
        ),
      };

      when(mockPresetProvider.presets).thenReturn(mockPresets);
      when(mockPresetProvider.activePresetId)
          .thenReturn(null); // Start inactive
      when(mockPresetProvider.setActivePreset('preset1')).thenAnswer((_) async {
        print("[TEST LOG] setActivePreset('preset1') called");
      });
      when(mockPresetProvider.sendCombinedDataToDevice(any))
          .thenAnswer((invocation) async {
        print(
            "[TEST LOG] sendCombinedDataToDevice called with args: ${invocation.positionalArguments}");
        await Future.delayed(const Duration(milliseconds: 10));
        print("[TEST LOG] sendCombinedDataToDevice finished");
        return true;
      });

      // Act
      await tester.pumpWidget(createTestableWidget(
        PresetsListPage(presetProvider: mockPresetProvider),
      ));
      await tester.pumpAndSettle();

      print('[TEST LOG] Tapping on Test Preset 1...');
      await tester.tap(find.text('Test Preset 1'));
      print('[TEST LOG] Tapped. Pumping and settling...');
      await tester.pumpAndSettle();
      print('[TEST LOG] Pumped and settled. Running verifications...');

      // Assert
      verify(mockPresetProvider.setActivePreset('preset1')).called(1);
      verify(mockPresetProvider.sendCombinedDataToDevice(any)).called(1);
    });
  });
}
