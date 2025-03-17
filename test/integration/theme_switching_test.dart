import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/settings/views/screens/settings_page.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mock AppLocalizations for testing
class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super(const Locale('en'));

  @override
  String translate(String key) {
    final Map<String, String> translations = {
      'settings': 'Settings',
      'app_settings': 'App Settings',
      'app_theme': 'App Theme',
      'language': 'Language',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'select_theme': 'Select Theme',
      'apply': 'Apply',
      'cancel': 'Cancel',
      'theme_changed': 'Theme changed to',
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

  group('Theme Switching Integration Test', () {
    testWidgets('should switch theme from light to dark and back',
        (WidgetTester tester) async {
      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      // Create a ThemeProvider
      final themeProvider = ThemeProvider();

      // Build the SettingsPage widget directly
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: const SettingsPage(),
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
      );
      await tester.pumpAndSettle();

      // Verify we're on the Settings page
      expect(find.text('App Theme'), findsOneWidget);

      // Find and tap on the App Theme option
      await tester.tap(find.text('App Theme'));
      await tester.pumpAndSettle();

      // Verify the theme dialog is shown
      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      // Select Dark Mode
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify theme has changed to dark
      expect(themeProvider.isDarkMode, isTrue);

      // Wait for the snackbar to disappear
      await tester.pump(const Duration(seconds: 2));

      // Tap on App Theme option again
      await tester.tap(find.text('App Theme'));
      await tester.pumpAndSettle();

      // Select Light Mode
      await tester.tap(find.text('Light Mode'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify theme has changed back to light
      expect(themeProvider.isDarkMode, isFalse);
    });

    testWidgets('should persist theme preference across app restarts',
        (WidgetTester tester) async {
      // Setup SharedPreferences with dark theme as the saved preference
      SharedPreferences.setMockInitialValues({
        'theme_preference': true,
      });

      // Create a ThemeProvider that will load from SharedPreferences
      final themeProvider = ThemeProvider();

      // Build the SettingsPage widget directly
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ThemeProvider>.value(
            value: themeProvider,
            child: const SettingsPage(),
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
      );
      await tester.pumpAndSettle();

      // Verify the theme is dark
      expect(themeProvider.isDarkMode, isTrue);

      // Change back to light theme for cleanup
      await tester.tap(find.text('App Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light Mode'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify theme has changed back to light
      expect(themeProvider.isDarkMode, isFalse);
    });
  });
}
