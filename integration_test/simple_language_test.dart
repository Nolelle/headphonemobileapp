import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'test_helper.dart';

// Simple widget that displays the current language
class LanguageDisplayWidget extends StatelessWidget {
  const LanguageDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Current Language: ${languageProvider.currentLocale.languageCode}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                languageProvider.setLanguage('fr');
              },
              child: const Text('Switch to French'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                languageProvider.setLanguage('en');
              },
              child: const Text('Switch to English'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock method channels
  setupMockMethodChannels();

  group('Simple Language Provider Test', () {
    testWidgets('should change language when buttons are pressed',
        (WidgetTester tester) async {
      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      // Create a LanguageProvider
      final languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      // Build the test widget
      await tester.pumpWidget(
        ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider,
          child: createTestableWidget(
            child: const LanguageDisplayWidget(),
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
      // Setup SharedPreferences with French as the saved language
      SharedPreferences.setMockInitialValues({
        'language_code': 'fr',
      });

      // Create a LanguageProvider that will load from SharedPreferences
      final languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      // Verify the language is French before building the widget
      expect(languageProvider.currentLocale.languageCode, equals('fr'));

      // Build the test widget
      await tester.pumpWidget(
        ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider,
          child: createTestableWidget(
            child: const LanguageDisplayWidget(),
            locale: languageProvider.currentLocale,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the widget shows French as the current language
      expect(find.text('Current Language: fr'), findsOneWidget);

      // Tap the button to switch to English
      await tester.tap(find.text('Switch to English'));
      await tester.pumpAndSettle();

      // Verify language has changed to English
      expect(find.text('Current Language: en'), findsOneWidget);
      expect(languageProvider.currentLocale.languageCode, equals('en'));

      // Verify the preference was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language_code'), equals('en'));
    });
  });
}
