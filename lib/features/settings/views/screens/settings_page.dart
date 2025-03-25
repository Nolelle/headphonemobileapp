// lib/features/settings/views/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appLocalizations.translate('settings')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Settings Section
              _buildSectionHeader(appLocalizations.translate('app_settings')),

              // Theme Toggle
              _buildSettingItem(
                icon: Icons.brightness_6,
                title: appLocalizations.translate('app_theme'),
                subtitle: isDarkMode
                    ? appLocalizations.translate('dark_mode')
                    : appLocalizations.translate('light_mode'),
                onTap: () {
                  _showThemeConfirmationDialog(themeProvider, appLocalizations);
                },
              ),

              // Language Selection
              _buildSettingItem(
                icon: Icons.language,
                title: appLocalizations.translate('language'),
                subtitle: languageProvider.getLanguageName(),
                onTap: () {
                  _showLanguageDialog(languageProvider, appLocalizations);
                },
              ),

              const SizedBox(height: 24),

              // FAQ Section
              _buildSectionHeader(appLocalizations.translate('faq')),
              _buildFaqItem(
                question: appLocalizations.translate('faq_clean'),
                answer: appLocalizations.translate('faq_clean_answer'),
              ),
              _buildFaqItem(
                question: appLocalizations.translate('faq_adjust'),
                answer: appLocalizations.translate('faq_adjust_answer'),
              ),
              _buildFaqItem(
                question: appLocalizations.translate('faq_test'),
                answer: appLocalizations.translate('faq_test_answer'),
              ),
              _buildFaqItem(
                question: appLocalizations.translate('faq_multiple'),
                answer: appLocalizations.translate('faq_multiple_answer'),
              ),

              const SizedBox(height: 24),

              // App Info
              _buildSectionHeader(appLocalizations.translate('about')),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: appLocalizations.translate('app_version'),
                subtitle: '1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: appLocalizations.translate('app_name'),
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(),
                    children: [
                      Text(
                        appLocalizations.translate('app_description'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ExpansionTile(
        title: Text(
          'Q. $question',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ans:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(answer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeConfirmationDialog(
      ThemeProvider themeProvider, AppLocalizations appLocalizations) {
    String selectedTheme =
        themeProvider.isDarkMode ? 'dark_mode' : 'light_mode';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(appLocalizations.translate('select_theme')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(appLocalizations.translate('light_mode')),
                  leading: Radio<String>(
                    value: 'light_mode',
                    groupValue: selectedTheme,
                    onChanged: (String? value) {
                      setState(() {
                        selectedTheme = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text(appLocalizations.translate('dark_mode')),
                  leading: Radio<String>(
                    value: 'dark_mode',
                    groupValue: selectedTheme,
                    onChanged: (String? value) {
                      setState(() {
                        selectedTheme = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(appLocalizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  final bool newIsDarkMode = selectedTheme == 'dark_mode';
                  await themeProvider.setTheme(newIsDarkMode);
                  if (context.mounted) {
                    Navigator.pop(context);
                    final themeName = appLocalizations.translate(selectedTheme);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${appLocalizations.translate('theme_changed')} $themeName'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Text(appLocalizations.translate('apply')),
              ),
            ],
          );
        });
      },
    );
  }

  void _showLanguageDialog(
      LanguageProvider languageProvider, AppLocalizations appLocalizations) {
    String selectedLanguage = languageProvider.currentLocale.languageCode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(appLocalizations.translate('select_language')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(appLocalizations.translate('english')),
                  leading: Radio<String>(
                    value: 'en',
                    groupValue: selectedLanguage,
                    onChanged: (String? value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text(appLocalizations.translate('french')),
                  leading: Radio<String>(
                    value: 'fr',
                    groupValue: selectedLanguage,
                    onChanged: (String? value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(appLocalizations.translate('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  await languageProvider.setLanguage(selectedLanguage);
                  if (context.mounted) {
                    Navigator.pop(context);
                    final languageName = languageProvider.getLanguageName();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${appLocalizations.translate('language_changed')} $languageName'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Text(appLocalizations.translate('apply')),
              ),
            ],
          );
        });
      },
    );
  }
}
