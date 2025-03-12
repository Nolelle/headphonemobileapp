import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'package:projects/features/settings/views/screens/settings_page.dart';
import 'package:projects/l10n/app_localizations.dart';

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
      'english': 'English',
      'french': 'Français',
      'select_language': 'Select Language',
      'cancel': 'Cancel',
      'apply': 'Apply',
      'language_changed': 'Language changed to',
      'faq': 'FAQ',
      'about': 'About',
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
  group('SettingsPage Widget Tests', () {
    late ThemeProvider themeProvider;
    late LanguageProvider languageProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      languageProvider = LanguageProvider();
    });

    testWidgets('should display settings page with correct sections',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<LanguageProvider>.value(
                value: languageProvider),
          ],
          child: createTestableWidget(const SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('App Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('FAQ'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('should show language dialog when language setting is tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<LanguageProvider>.value(
                value: languageProvider),
          ],
          child: createTestableWidget(const SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Act - tap on the language setting
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
    });

    testWidgets('should change language when selecting a different language',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<LanguageProvider>.value(
                value: languageProvider),
          ],
          child: createTestableWidget(const SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Initial language should be English
      expect(languageProvider.currentLocale.languageCode, 'en');

      // Act - tap on the language setting
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Select French
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Assert
      expect(languageProvider.currentLocale.languageCode, 'fr');
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should not change language when canceling the dialog',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
            ChangeNotifierProvider<LanguageProvider>.value(
                value: languageProvider),
          ],
          child: createTestableWidget(const SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Initial language should be English
      expect(languageProvider.currentLocale.languageCode, 'en');

      // Act - tap on the language setting
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Select French
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(languageProvider.currentLocale.languageCode, 'en');
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
