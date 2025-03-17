import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projects/features/settings/views/screens/settings_page.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/l10n/app_localizations.dart';
import 'test_helper.dart';

// Widget that displays localized text to verify language changes
class LanguageTestWidget extends StatelessWidget {
  const LanguageTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        // This title will change based on the current language
        title: Text(localizations.translate('settings')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display current language code
            Text(
              'Current Language: ${languageProvider.currentLocale.languageCode}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // These texts will change based on the current language
            Text(
              localizations.translate('language'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              localizations.translate('app_theme'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            // The apply button text will change between languages
            ElevatedButton(
              onPressed: () {},
              child: Text(localizations.translate('apply')),
            ),
            const SizedBox(height: 20),
            // Buttons to switch languages
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    languageProvider.setLanguage('en');
                  },
                  child: const Text('Switch to English'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    languageProvider.setLanguage('fr');
                  },
                  child: const Text('Switch to French'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A simpler test that just verifies language code changes
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Language Switching Test', () {
    late LanguageProvider languageProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();
    });

    testWidgets('should switch language from English to French and back',
        (WidgetTester tester) async {
      // Build a simpler test widget
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LanguageProvider>.value(
            value: languageProvider,
            child: Builder(
              builder: (context) {
                final provider = Provider.of<LanguageProvider>(context);
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Just display current language code
                        Text(
                            'Current Language: ${provider.currentLocale.languageCode}'),
                        const SizedBox(height: 20),
                        // Simple buttons to switch languages
                        ElevatedButton(
                          onPressed: () {
                            provider.setLanguage('en');
                          },
                          child: const Text('Switch to English'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            provider.setLanguage('fr');
                          },
                          child: const Text('Switch to French'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial language is English
      expect(find.text('Current Language: en'), findsOneWidget);
      expect(languageProvider.currentLocale.languageCode, equals('en'));

      // Tap the button to switch to French
      await tester.tap(find.text('Switch to French'));
      await tester.pumpAndSettle();

      // Verify language has changed to French
      expect(find.text('Current Language: fr'), findsOneWidget);
      expect(languageProvider.currentLocale.languageCode, equals('fr'));

      // Tap the button to switch back to English
      await tester.tap(find.text('Switch to English'));
      await tester.pumpAndSettle();

      // Verify language has changed back to English
      expect(find.text('Current Language: en'), findsOneWidget);
      expect(languageProvider.currentLocale.languageCode, equals('en'));
    });

    testWidgets('should persist language preference across app restarts',
        (WidgetTester tester) async {
      // First instance of the app
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LanguageProvider>.value(
            value: languageProvider,
            child: Builder(
              builder: (context) {
                final provider = Provider.of<LanguageProvider>(context);
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            'Current Language: ${provider.currentLocale.languageCode}'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            provider.setLanguage('en');
                          },
                          child: const Text('Switch to English'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            provider.setLanguage('fr');
                          },
                          child: const Text('Switch to French'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Change language to French
      await tester.tap(find.text('Switch to French'));
      await tester.pumpAndSettle();
      expect(find.text('Current Language: fr'), findsOneWidget);

      // Create new LanguageProvider to simulate app restart
      final newLanguageProvider = LanguageProvider();
      await newLanguageProvider.loadLanguage();

      // Second instance of the app (simulated restart)
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LanguageProvider>.value(
            value: newLanguageProvider,
            child: Builder(
              builder: (context) {
                final provider = Provider.of<LanguageProvider>(context);
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            'Current Language: ${provider.currentLocale.languageCode}'),
                        const SizedBox(height: 20),
                        // Language switching buttons are not needed for this test
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Language should still be French after restart
      expect(find.text('Current Language: fr'), findsOneWidget);
      expect(newLanguageProvider.currentLocale.languageCode, equals('fr'));
    });
  });
}
