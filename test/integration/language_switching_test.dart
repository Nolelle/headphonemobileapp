import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Language Switching Integration Test', () {
    testWidgets('should switch language from English to French and back',
        (WidgetTester tester) async {
      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings tab
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify we're on the Settings page
      expect(find.text('Settings'), findsOneWidget);

      // Find and tap on the Language option
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      // Verify the language dialog is shown
      expect(find.text('Select Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);

      // Select French
      await tester.tap(find.text('Français'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify language has changed to French
      // Note: The actual text will depend on your French translations
      // These are examples and should be replaced with actual French translations
      expect(find.text('Paramètres'), findsOneWidget);

      // Wait for the snackbar to disappear
      await tester.pump(const Duration(seconds: 2));

      // Tap on Language option again (now in French)
      await tester.tap(find.text('Langue'));
      await tester.pumpAndSettle();

      // Select English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Tap Apply (in French)
      await tester.tap(find.text('Appliquer'));
      await tester.pumpAndSettle();

      // Verify language has changed back to English
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should persist language preference across app restarts',
        (WidgetTester tester) async {
      // Setup SharedPreferences with French as the saved language
      SharedPreferences.setMockInitialValues({
        'language_code': 'fr',
      });

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings tab
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify the app started in French
      // Note: Replace with actual French translations
      expect(find.text('Paramètres'), findsOneWidget);

      // Change back to English for cleanup
      await tester.tap(find.text('Langue'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Appliquer'));
      await tester.pumpAndSettle();

      // Verify language has changed back to English
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
