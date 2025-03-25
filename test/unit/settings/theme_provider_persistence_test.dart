import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider Persistence Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      // Reset shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    // Helper function to wait for the theme provider to load preferences
    Future<void> waitForThemeLoad() async {
      // Wait a bit for the async theme loading to complete
      await Future.delayed(const Duration(milliseconds: 100));
    }

    test('should load default theme (light mode) when no preferences exist',
        () async {
      // Set up empty shared preferences
      SharedPreferences.setMockInitialValues({});

      // Create provider which will load preferences
      themeProvider = ThemeProvider();

      // Wait for the preferences to load
      await waitForThemeLoad();

      // Verify default value is used
      expect(themeProvider.isDarkMode, false);
      expect(themeProvider.themeMode, equals(ThemeMode.light));
    });

    test('should load saved theme preference (dark mode)', () async {
      // Set up shared preferences with dark mode enabled
      SharedPreferences.setMockInitialValues({
        'theme_preference': true, // true = dark mode
      });

      // Create provider which will load preferences
      themeProvider = ThemeProvider();

      // Wait for the preferences to load
      await waitForThemeLoad();

      // Verify saved value is loaded
      expect(themeProvider.isDarkMode, true);
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
    });

    test('should save theme preference when toggled', () async {
      // Start with empty preferences
      SharedPreferences.setMockInitialValues({});

      // Create provider
      themeProvider = ThemeProvider();

      // Wait for the preferences to load
      await waitForThemeLoad();

      // Toggle theme (from default light to dark)
      await themeProvider.toggleTheme();

      // Verify preference was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('theme_preference'), true);
      expect(themeProvider.isDarkMode, true);
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
    });

    test('should save theme preference when explicitly set', () async {
      // Start with empty preferences
      SharedPreferences.setMockInitialValues({});

      // Create provider
      themeProvider = ThemeProvider();

      // Wait for the preferences to load
      await waitForThemeLoad();

      // Set theme explicitly to dark
      await themeProvider.setTheme(true);

      // Verify preference was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('theme_preference'), true);
      expect(themeProvider.isDarkMode, true);

      // Change back to light mode
      await themeProvider.setTheme(false);

      // Verify preference was updated
      final updatedPrefs = await SharedPreferences.getInstance();
      expect(updatedPrefs.getBool('theme_preference'), false);
      expect(themeProvider.isDarkMode, false);
    });

    test('should not emit notification if theme is set to current value',
        () async {
      // Start with dark mode already set
      SharedPreferences.setMockInitialValues({
        'theme_preference': true,
      });

      // Create provider
      themeProvider = ThemeProvider();

      // Wait for the preferences to load
      await waitForThemeLoad();

      // Count notifications - reset counter after initial load
      int notificationCount = 0;
      themeProvider.addListener(() {
        notificationCount++;
      });

      // Set theme to the same value (dark)
      await themeProvider.setTheme(true);

      // No notification should be sent since value didn't change
      expect(notificationCount, 0);

      // Change to light mode should notify
      await themeProvider.setTheme(false);
      expect(notificationCount, 1);
    });
  });
}
