import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/settings/providers/language_provider.dart';

void main() {
  group('LanguageProvider Tests', () {
    late LanguageProvider provider;

    setUp(() {
      provider = LanguageProvider();
    });

    test('initial locale should be English', () {
      expect(provider.currentLocale.languageCode, 'en');
    });

    test('getLanguageName should return correct language name', () {
      // Default is English
      expect(provider.getLanguageName(), 'English');

      // Set to French
      provider.setLanguage('fr');
      expect(provider.getLanguageName(), 'Français');

      // Set back to English
      provider.setLanguage('en');
      expect(provider.getLanguageName(), 'English');
    });

    test('setLanguage should update currentLocale', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await provider.setLanguage('fr');

      // Assert
      expect(provider.currentLocale.languageCode, 'fr');
    });

    test('loadLanguage should load saved language preference', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'language_code': 'fr',
      });

      // Act
      await provider.loadLanguage();

      // Assert
      expect(provider.currentLocale.languageCode, 'fr');
    });

    test('loadLanguage should default to English if no preference is saved',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await provider.loadLanguage();

      // Assert
      expect(provider.currentLocale.languageCode, 'en');
    });

    test('setLanguage should save preference to SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await provider.setLanguage('fr');

      // Get the saved preference directly
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language_code');

      // Assert
      expect(savedLanguage, 'fr');
    });
  });
}
