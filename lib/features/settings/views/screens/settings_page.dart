// lib/features/settings/views/screens/settings_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _currentLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Settings Section
              _buildSectionHeader('App Settings'),

              // Theme Toggle
              _buildSettingItem(
                icon: Icons.brightness_6,
                title: 'App Theme',
                subtitle: _isDarkMode ? 'Dark Mode' : 'Light Mode',
                onTap: () {
                  _showThemeConfirmationDialog();
                },
              ),

              // Language Selection
              _buildSettingItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: _currentLanguage,
                onTap: () {
                  _showLanguageDialog();
                },
              ),

              const SizedBox(height: 24),

              // FAQ Section
              _buildSectionHeader('Frequently Asked Questions'),
              _buildFaqItem(
                question: 'How do I clean and maintain my headphones?',
                answer:
                    'Regular cleaning is essential. Use a soft, dry cloth to wipe the exterior daily, and follow the specific cleaning instructions provided in the app. We also recommend scheduling professional cleanings every few months.',
              ),
              _buildFaqItem(
                question: 'How can I adjust the settings on my headphones?',
                answer:
                    'You can adjust your headphone settings through the app. This includes changing the volume, selecting different listening programs. Just go to the equalizer and change according to your environment.',
              ),
              _buildFaqItem(
                question: 'How can I perform a sound test?',
                answer:
                    'The sound test is extremely easy to complete. A sound will be played at different frequencies. And the sound keep getting louder overtime. You have to click the button as soon as you hear the sound. You have to do this for every frequency. You responses will be recorded a preset will be made according to that. You can then use that preset in your headphones.',
              ),
              _buildFaqItem(
                question: 'Can I do more than one test?',
                answer:
                    'Yes of course! You can do as many Tests as you want, conducting every test creates a new preset in the app, you can then use that preset in your headphones. With this feature, you can use different presets for different environments such as listening to music, or sitting in transit vehicles.',
              ),

              const SizedBox(height: 24),

              // App Info
              _buildSectionHeader('About'),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: () {},
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
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(133, 86, 169, 1.00),
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
          color: const Color.fromRGBO(133, 86, 169, 1.00),
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

  void _showThemeConfirmationDialog() {
    String selectedTheme = _isDarkMode ? 'Dark Mode' : 'Light Mode';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Light Mode'),
                  leading: Radio<String>(
                    value: 'Light Mode',
                    groupValue: selectedTheme,
                    onChanged: (String? value) {
                      setState(() {
                        selectedTheme = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Dark Mode'),
                  leading: Radio<String>(
                    value: 'Dark Mode',
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
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final bool newIsDarkMode = selectedTheme == 'Dark Mode';
                  this.setState(() {
                    _isDarkMode = newIsDarkMode;
                  });
                  Navigator.pop(context);
                  // Theme implementation will be added later
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Theme changed to $selectedTheme'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showLanguageDialog() {
    String selectedLanguage = _currentLanguage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('English'),
                  leading: Radio<String>(
                    value: 'English',
                    groupValue: selectedLanguage,
                    onChanged: (String? value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('French'),
                  leading: Radio<String>(
                    value: 'French',
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
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  this.setState(() {
                    _currentLanguage = selectedLanguage;
                  });
                  Navigator.pop(context);
                  // Language implementation will be added later
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $selectedLanguage'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('Apply'),
              ),
            ],
          );
        });
      },
    );
  }
}
