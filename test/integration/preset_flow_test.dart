import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projects/features/presets/views/screens/preset_list_page.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';
import 'package:projects/l10n/app_localizations.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mock AppLocalizations for testing
class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super(const Locale('en'));

  @override
  String translate(String key) {
    final Map<String, String> translations = {
      'no_presets': 'No presets available. Create a new preset to get started.',
      'edit_preset': 'Edit Preset',
      'edit': 'Edit',
      'delete': 'Delete',
      'confirm_delete': 'Confirm Delete',
      'confirm_delete_message': 'Are you sure you want to delete',
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock method channels for plugins
  setUp(() {
    // Mock Bluetooth plugin
    const MethodChannel bluetoothChannel =
        MethodChannel('com.headphonemobileapp/bluetooth');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      bluetoothChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'isBluetoothEnabled':
            return true;
          case 'getScannedDevices':
            return [];
          case 'startScan':
          case 'stopScan':
          case 'connectToDevice':
          case 'disconnectDevice':
            return null;
          default:
            return null;
        }
      },
    );

    // Mock Settings plugin
    const MethodChannel settingsChannel =
        MethodChannel('com.headphonemobileapp/settings');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      settingsChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getDeviceModel':
            return 'Test Device';
          default:
            return null;
        }
      },
    );
  });

  group('Preset Flow Integration Tests', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Create, edit, and delete a preset',
        (WidgetTester tester) async {
      // Create a PresetProvider with an empty repository
      final presetRepository = PresetRepository();
      final presetProvider = PresetProvider(presetRepository);
      await presetProvider.loadPresets();

      // Create a LanguageProvider for localization
      final languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      // Build the PresetsListPage widget directly with proper localization
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PresetProvider>.value(
              value: presetProvider,
            ),
            ChangeNotifierProvider<LanguageProvider>.value(
              value: languageProvider,
            ),
          ],
          child: MaterialApp(
            home: PresetsListPage(
              presetProvider: presetProvider,
            ),
            localizationsDelegates: [
              MockLocalizationsDelegate(), // Use our mock localization
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fr', ''),
            ],
            locale: const Locale('en', ''), // Force English for tests
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we're on the presets page by checking for the empty state message
      expect(find.textContaining('No presets available'), findsOneWidget);

      // Create a new preset by tapping the add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify we're on the preset edit page
      expect(find.text('Edit Preset'), findsOneWidget);

      // Edit the preset name
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(TextField).first, 'Integration Test Preset');
      await tester.pumpAndSettle();

      // Adjust the overall volume
      final Finder slider = find.byType(Slider).first;
      await tester.drag(slider, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();

      // Toggle background noise reduction
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Go back to presets list
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify the preset was created
      expect(find.text('Integration Test Preset'), findsOneWidget);

      // Tap on the preset to activate it
      await tester.tap(find.text('Integration Test Preset'));
      await tester.pumpAndSettle();

      // Verify the edit and delete buttons appear
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Edit the preset
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Change the preset name
      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Updated Preset');
      await tester.pumpAndSettle();

      // Go back to presets list
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify the preset was updated
      expect(find.text('Updated Preset'), findsOneWidget);

      // Tap on the preset to activate it
      await tester.tap(find.text('Updated Preset'));
      await tester.pumpAndSettle();

      // Delete the preset
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Verify the preset was deleted
      expect(find.textContaining('No presets available'), findsOneWidget);
    });
  });
}
