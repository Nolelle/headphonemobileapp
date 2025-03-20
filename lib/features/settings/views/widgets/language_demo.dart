import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';

class LanguageDemo extends StatelessWidget {
  const LanguageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.translate('language_demo_title') ??
                  'Language Demo',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            // Just display the sample text in the current language
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                appLocalizations.translate('sample_text') ??
                    'This is a sample text that will be displayed in the selected language.',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 24.0),
            // Language toggle buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    languageProvider.setLanguage('en');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        languageProvider.currentLocale.languageCode == 'en'
                            ? Theme.of(context).primaryColor
                            : null,
                    foregroundColor:
                        languageProvider.currentLocale.languageCode == 'en'
                            ? Colors.white
                            : null,
                  ),
                  child: const Text('English'),
                ),
                ElevatedButton(
                  onPressed: () {
                    languageProvider.setLanguage('fr');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        languageProvider.currentLocale.languageCode == 'fr'
                            ? Theme.of(context).primaryColor
                            : null,
                    foregroundColor:
                        languageProvider.currentLocale.languageCode == 'fr'
                            ? Colors.white
                            : null,
                  ),
                  child: const Text('Français'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
