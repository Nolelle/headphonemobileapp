import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/settings/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LanguageProvider Persistence Tests', () {
    late LanguageProvider languageProvider;

    setUp(() {
      // Reset shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should load default language (English) when no preferences exist',
        () async {
      // Set up empty shared preferences
      SharedPreferences.setMockInitialValues({});

      // Create provider and load language
      languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      // Verify default value is used
      expect(languageProvider.currentLocale.languageCode, equals('en'));
      expect(languageProvider.getLanguageName(), equals('English'));
    });

    test('should load saved language preference (French)', () async {
      // Set up shared preferences with French language
      SharedPreferences.setMockInitialValues({
        'language_code': 'fr',
      });

      // Create provider and load language
      languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      // Verify saved value is loaded
      expect(languageProvider.currentLocale.languageCode, equals('fr'));
      expect(languageProvider.getLanguageName(), equals('Français'));
    });

    test('should save language preference when changed', () async {
      // Start with empty preferences
      SharedPreferences.setMockInitialValues({});

      // Create provider and load default language
      languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      // Change language to French
      await languageProvider.setLanguage('fr');

      // Verify preference was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('language_code'), equals('fr'));
      expect(languageProvider.currentLocale.languageCode, equals('fr'));
      expect(languageProvider.getLanguageName(), equals('Français'));

      // Change back to English
      await languageProvider.setLanguage('en');

      // Verify preference was updated
      final updatedPrefs = await SharedPreferences.getInstance();
      expect(updatedPrefs.getString('language_code'), equals('en'));
      expect(languageProvider.currentLocale.languageCode, equals('en'));
      expect(languageProvider.getLanguageName(), equals('English'));
    });

    test('should notify listeners when language is changed', () async {
      // Start with default settings
      SharedPreferences.setMockInitialValues({});

      // Create provider and load language (this will notify once)
      languageProvider = LanguageProvider();
      await languageProvider.loadLanguage();

      // Count notifications after loading
      int notificationCount = 0;
      languageProvider.addListener(() {
        notificationCount++;
      });

      // Change language to French
      await languageProvider.setLanguage('fr');

      // Should have notified once
      expect(notificationCount, 1);

      // Change to a different language
      await languageProvider.setLanguage('en');
      expect(notificationCount, 2);
    });
  });
}
