import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Switching Integration Test', () {
    testWidgets('should switch theme from light to dark and back',
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
      // Check for dark theme by looking at scaffold background color
      final ScaffoldWidget =
          find.byType(Scaffold).evaluate().first.widget as Scaffold;
      expect(ScaffoldWidget.backgroundColor, isNot(Colors.white));

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
      final ScaffoldWidgetAfterSwitch =
          find.byType(Scaffold).evaluate().first.widget as Scaffold;
      expect(ScaffoldWidgetAfterSwitch.backgroundColor, isNot(Colors.black));
    });

    testWidgets('should persist theme preference across app restarts',
        (WidgetTester tester) async {
      // Setup SharedPreferences with dark theme as the saved preference
      SharedPreferences.setMockInitialValues({
        'theme_preference': true,
      });

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings tab
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify the app started in dark theme
      final ScaffoldWidget =
          find.byType(Scaffold).evaluate().first.widget as Scaffold;
      expect(ScaffoldWidget.backgroundColor, isNot(Colors.white));

      // Change back to light theme for cleanup
      await tester.tap(find.text('App Theme'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light Mode'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // Verify theme has changed back to light
      final ScaffoldWidgetAfterSwitch =
          find.byType(Scaffold).evaluate().first.widget as Scaffold;
      expect(ScaffoldWidgetAfterSwitch.backgroundColor, isNot(Colors.black));
    });
  });
}
