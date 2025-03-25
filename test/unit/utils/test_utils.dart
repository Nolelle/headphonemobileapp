import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:projects/l10n/app_localizations.dart';
import 'package:projects/l10n/translations/en.dart';
import 'package:projects/l10n/translations/fr.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/features/settings/providers/language_provider.dart';

// Mock AppLocalizations for testing
class MockAppLocalizations extends AppLocalizations {
  @override
  final Locale locale;
  late Map<String, String> _localizedStrings;

  MockAppLocalizations({this.locale = const Locale('en')}) : super(locale) {
    // Use actual translations from the app
    if (locale.languageCode == 'fr') {
      _localizedStrings = frTranslations;
    } else {
      _localizedStrings = enTranslations;
    }
  }

  @override
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class MockLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      MockAppLocalizations(locale: locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

// Wrap widget with MaterialApp for testing
Widget wrapWithMaterialApp(Widget widget,
    {Locale locale = const Locale('en')}) {
  return MaterialApp(
    localizationsDelegates: [
      MockLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('fr'),
    ],
    locale: locale,
    home: widget,
  );
}

// Wrap widget with necessary providers for testing
Widget wrapWithProviders(
  Widget widget, {
  PresetProvider? presetProvider,
  SoundTestProvider? soundTestProvider,
  BluetoothProvider? bluetoothProvider,
  ThemeProvider? themeProvider,
  LanguageProvider? languageProvider,
  Locale locale = const Locale('en'),
}) {
  return MultiProvider(
    providers: [
      if (presetProvider != null)
        ChangeNotifierProvider<PresetProvider>.value(value: presetProvider),
      if (soundTestProvider != null)
        ChangeNotifierProvider<SoundTestProvider>.value(
            value: soundTestProvider),
      if (bluetoothProvider != null)
        ChangeNotifierProvider<BluetoothProvider>.value(
            value: bluetoothProvider),
      if (themeProvider != null)
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      if (languageProvider != null)
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
    ],
    child: wrapWithMaterialApp(widget, locale: locale),
  );
}

// Setup mock SharedPreferences for testing
SharedPreferences setupMockSharedPreferences() {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance() as SharedPreferences;
}

// Setup mock MethodChannel for Bluetooth testing
void setupMockBluetoothChannel({
  bool isBluetoothEnabled = true,
  List<Map<String, dynamic>> scannedDevices = const [],
  bool connectSuccess = true,
}) {
  const MethodChannel channel =
      MethodChannel('com.headphonemobileapp/bluetooth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isBluetoothEnabled':
          return isBluetoothEnabled;
        case 'getScannedDevices':
          return scannedDevices;
        case 'startScan':
        case 'stopScan':
          return null;
        case 'connectToDevice':
          return connectSuccess;
        case 'disconnectDevice':
          return true;
        case 'getConnectedDevice':
          return scannedDevices.isNotEmpty ? scannedDevices.first : null;
        case 'isAudioDeviceConnected':
          return connectSuccess;
        case 'getBluetoothAudioType':
          return 0; // None
        default:
          return null;
      }
    },
  );
}

// Setup mock AudioPlayer for sound test
void setupMockAudioPlayer(AudioPlayer mockPlayer) {
  when(mockPlayer.play(any as Source,
          volume: anyNamed('volume'), balance: anyNamed('balance')))
      .thenAnswer((_) async => {});
  when(mockPlayer.setVolume(any as double)).thenAnswer((_) async => {});
  when(mockPlayer.setBalance(any as double)).thenAnswer((_) async => {});
  when(mockPlayer.stop()).thenAnswer((_) async => {});
}
