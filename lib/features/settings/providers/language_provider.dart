import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;

  // Key for storing language preference
  static const String _languageKey = 'language_code';

  // Initialize with saved language or default to English
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(languageCode, '');
    notifyListeners();
  }

  // Save language preference
  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // Set current language
  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode, '');
    await _saveLanguage(languageCode);
    notifyListeners();
  }

  // Get language name based on code
  String getLanguageName() {
    switch (_currentLocale.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
      default:
        return 'English';
    }
  }
}
