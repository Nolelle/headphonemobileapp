import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/l10n/app_localizations.dart';
import 'package:projects/l10n/translations/en.dart';
import 'package:projects/l10n/translations/fr.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mock AppLocalizations for testing using actual translations
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

// Set up mock method channels for plugins
void setupMockMethodChannels() {
  // Mock Bluetooth plugin
  const MethodChannel bluetoothChannel =
      MethodChannel('com.headphonemobileapp/bluetooth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    bluetoothChannel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isBluetoothEnabled':
          return true;
        case 'getScannedDevices':
          return [
            {
              'id': 'device1',
              'name': 'Test Device',
              'type': 'classic',
            }
          ];
        case 'startScan':
          return true;
        case 'stopScan':
          return true;
        case 'connectToDevice':
          return true;
        case 'disconnectDevice':
          return true;
        case 'isAudioDeviceConnected':
          return true;
        case 'getConnectedDevice':
          return {
            'id': 'device1',
            'name': 'Test Device',
            'type': 'classic',
          };
        case 'getBluetoothAudioType':
          return 'classic'; // Return a valid string instead of null
        case 'getBatteryLevel':
          return 80;
        case 'forceAudioRoutingToBluetooth':
          return true;
        default:
          return null;
      }
    },
  );

  // Mock Settings plugin
  const MethodChannel settingsChannel =
      MethodChannel('com.headphonemobileapp/settings');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    settingsChannel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getDeviceModel':
          return 'Test Device';
        default:
          return null;
      }
    },
  );
}

// Helper to create a testable widget with proper localization
Widget createTestableWidget({
  required Widget child,
  Locale locale = const Locale('en', ''),
}) {
  return MaterialApp(
    localizationsDelegates: [
      MockLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', ''),
      Locale('fr', ''),
    ],
    locale: locale,
    home: child,
  );
}
