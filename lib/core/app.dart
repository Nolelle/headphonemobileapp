import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../features/presets/models/preset.dart';
import '../features/bluetooth/providers/bluetooth_provider.dart';
import '../features/bluetooth/views/widgets/bluetooth_wrapper.dart';
import '../features/settings/providers/theme_provider.dart';
import '../features/settings/providers/language_provider.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import 'main_nav.dart';

class MyApp extends StatelessWidget {
  final List<Preset> presetData;

  const MyApp({super.key, required this.presetData});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;

        // Create custom theme with explicit app bar theme
        final customLightTheme = lightTheme.copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(133, 86, 169, 1.00),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 4.0,
          ),
        );

        final customDarkTheme = darkTheme.copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(104, 92, 162, 1.00),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 4.0,
          ),
        );

        return MaterialApp(
          title: 'Headphone App',
          theme: customLightTheme,
          darkTheme: customDarkTheme,
          themeMode: themeProvider.themeMode,
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('fr', ''), // French
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const BluetoothWrapper(
            child: MainNavigation(presetData: {},),
          ),
        );
      },
    );
  }
}
