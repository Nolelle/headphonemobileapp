import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider provider;

    setUp(() {
      provider = ThemeProvider();
    });

    test('initial theme should be light mode', () {
      expect(provider.isDarkMode, false);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('toggleTheme should switch between light and dark mode', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      expect(provider.isDarkMode, false); // Initially light mode

      // Act - toggle to dark mode
      await provider.toggleTheme();

      // Assert
      expect(provider.isDarkMode, true);
      expect(provider.themeMode, ThemeMode.dark);

      // Act - toggle back to light mode
      await provider.toggleTheme();

      // Assert
      expect(provider.isDarkMode, false);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('setTheme should update theme mode', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act - set to dark mode
      await provider.setTheme(true);

      // Assert
      expect(provider.isDarkMode, true);
      expect(provider.themeMode, ThemeMode.dark);

      // Act - set to light mode
      await provider.setTheme(false);

      // Assert
      expect(provider.isDarkMode, false);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('setTheme should not notify listeners if theme is not changed',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      // Act - set to light mode when already in light mode
      await provider.setTheme(false);

      // Assert
      expect(notified, false);
    });

    test('theme preference should be saved to SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act - set to dark mode
      await provider.setTheme(true);

      // Get the saved preference directly
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getBool('theme_preference');

      // Assert
      expect(savedTheme, true);
    });

    test('loadThemePreference should load saved theme preference', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'theme_preference': true,
      });

      // Act - create a new provider which will load the preference
      final newProvider = ThemeProvider();

      // Wait for the async operation to complete
      await Future.delayed(Duration.zero);

      // Assert
      expect(newProvider.isDarkMode, true);
      expect(newProvider.themeMode, ThemeMode.dark);
    });
  });
}
