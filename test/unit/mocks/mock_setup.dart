import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/features/settings/providers/theme_provider.dart';
import 'package:projects/features/settings/providers/language_provider.dart';

@GenerateMocks([
  PresetRepository,
  PresetProvider,
  SoundTestRepository,
  SoundTestProvider,
  BluetoothProvider,
  ThemeProvider,
  LanguageProvider,
  AudioPlayer,
  SharedPreferences,
  MethodChannel,
])
void main() {}
