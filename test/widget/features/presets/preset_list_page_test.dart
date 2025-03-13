import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/views/screens/preset_list_page.dart';

// Mock classes for localization
import 'package:projects/l10n/app_localizations.dart';
import '../../../unit/mocks/mock_preset_provider.mocks.dart';

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

    setUp(() {
      mockPresetProvider = MockPresetProvider();
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
        home: ChangeNotifierProvider<PresetProvider>.value(
          value: mockPresetProvider,
          child: child,
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
      when(mockPresetProvider.activePresetId).thenReturn('preset1');

      // Act
      await tester.pumpWidget(createTestableWidget(
        PresetsListPage(presetProvider: mockPresetProvider),
      ));
      await tester.pumpAndSettle();

      // Dump the widget tree to see what's actually there
      debugDumpApp();

      // Assert - look for text on buttons instead of icons
      expect(find.text('Test Preset 1'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
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
      when(mockPresetProvider.activePresetId).thenReturn(null);

      // Act
      await tester.pumpWidget(createTestableWidget(
        PresetsListPage(presetProvider: mockPresetProvider),
      ));
      await tester.pumpAndSettle();

      // Tap on the preset
      await tester.tap(find.text('Test Preset 1'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockPresetProvider.setActivePreset('preset1')).called(1);
    });
  });
}
