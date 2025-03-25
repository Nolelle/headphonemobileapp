import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/settings/views/screens/settings_page.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'test_helper.dart';

// Widget that displays content with theme-dependent styling
class ThemeTestWidget extends StatelessWidget {
  const ThemeTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use theme-dependent colors to verify theme is actually applied
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Theme Test'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // This text will have different colors based on the theme
            Text(
              'Current Theme: ${isDark ? "Dark" : "Light"}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            // This container will have different colors based on the theme
            Container(
              width: 200,
              height: 100,
              color: Theme.of(context).colorScheme.primary,
              child: Center(
                child: Text(
                  'Theme-colored box',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                themeProvider.setTheme(true); // Switch to Dark Mode
              },
              child: const Text('Switch to Dark Mode'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                themeProvider.setTheme(false); // Switch to Light Mode
              },
              child: const Text('Switch to Light Mode'),
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

  group('Theme Switching Integration Test', () {
    testWidgets('should switch theme from light to dark and back',
        (WidgetTester tester) async {
      // Setup SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      // Create a ThemeProvider
      final themeProvider = ThemeProvider();

      // Allow time for the ThemeProvider to load preferences
      await tester.pump(const Duration(milliseconds: 500));

      // Build the test widget with MaterialApp using the ThemeProvider's themeMode
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: Builder(
            builder: (context) {
              final provider = Provider.of<ThemeProvider>(context);
              return MaterialApp(
                themeMode: provider.themeMode,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                home: const ThemeTestWidget(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial theme is Light
      expect(find.text('Current Theme: Light'), findsOneWidget);
      expect(themeProvider.isDarkMode, isFalse);

      // Verify theme-dependent UI elements
      final scaffoldFinder = find.byType(Scaffold);
      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(
          scaffold.backgroundColor, isNot(Colors.grey[900])); // Not dark color

      // Tap the button to switch to Dark Mode
      await tester.tap(find.text('Switch to Dark Mode'));
      await tester.pumpAndSettle();

      // Verify theme has changed to Dark
      expect(find.text('Current Theme: Dark'), findsOneWidget);
      expect(themeProvider.isDarkMode, isTrue);

      // Verify theme-dependent UI elements have changed
      final darkScaffoldFinder = find.byType(Scaffold);
      final darkScaffold = tester.widget<Scaffold>(darkScaffoldFinder);
      expect(
          darkScaffold.backgroundColor, isNot(Colors.white)); // Not light color

      // Tap the button to switch back to Light Mode
      await tester.tap(find.text('Switch to Light Mode'));
      await tester.pumpAndSettle();

      // Verify theme has changed back to Light
      expect(find.text('Current Theme: Light'), findsOneWidget);
      expect(themeProvider.isDarkMode, isFalse);

      // Verify theme-dependent UI elements have changed back
      final lightScaffoldFinder = find.byType(Scaffold);
      final lightScaffold = tester.widget<Scaffold>(lightScaffoldFinder);
      expect(lightScaffold.backgroundColor,
          isNot(Colors.grey[900])); // Not dark color
    });

    testWidgets('should persist theme preference across app restarts',
        (WidgetTester tester) async {
      // Setup SharedPreferences with dark theme as the saved preference
      SharedPreferences.setMockInitialValues({
        'theme_preference': true,
      });

      // Create a ThemeProvider that will load from SharedPreferences
      final themeProvider = ThemeProvider();

      // Allow time for the ThemeProvider to load preferences
      await tester.pump(const Duration(milliseconds: 500));

      // Verify the theme is Dark before building the widget
      expect(themeProvider.isDarkMode, isTrue,
          reason: 'Theme should be dark based on SharedPreferences');

      // Build the test widget with MaterialApp using the ThemeProvider's themeMode
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
          child: Builder(
            builder: (context) {
              final provider = Provider.of<ThemeProvider>(context);
              return MaterialApp(
                themeMode: provider.themeMode,
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                home: const ThemeTestWidget(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the widget shows Dark as the current theme
      expect(find.text('Current Theme: Dark'), findsOneWidget);

      // Verify theme-dependent UI elements reflect dark theme
      final containerFinder = find.byType(Container);
      final container = tester.widget<Container>(containerFinder);
      final containerColor = container.color;
      expect(containerColor, isNot(ThemeData.light().colorScheme.primary));

      // Tap the button to switch to Light Mode
      await tester.tap(find.text('Switch to Light Mode'));
      await tester.pumpAndSettle();

      // Verify theme has changed to Light
      expect(find.text('Current Theme: Light'), findsOneWidget);
      expect(themeProvider.isDarkMode, isFalse);

      // Verify theme-dependent UI elements have changed
      final lightContainerFinder = find.byType(Container);
      final lightContainer = tester.widget<Container>(lightContainerFinder);
      final lightContainerColor = lightContainer.color;
      expect(lightContainerColor, isNot(ThemeData.dark().colorScheme.primary));

      // Verify the preference was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('theme_preference'), isFalse);
    });
  });
}
