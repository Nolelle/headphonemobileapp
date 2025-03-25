import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound_test.dart';

class SoundTestRepository {
  static const String _soundTestsKey = 'soundTestsMap';
  SharedPreferences? _prefs;

  // Constructor that allows injection for testing
  SoundTestRepository({SharedPreferences? sharedPreferences}) {
    _prefs = sharedPreferences;
  }

  Future<SharedPreferences> get _sharedPreferences async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<Map<String, SoundTest>> getAllSoundTests() async {
    final prefs = await _sharedPreferences;
    final jsonString = prefs.getString(_soundTestsKey);
    if (jsonString == null) return {};

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return {
        for (var entry in jsonMap.entries)
          entry.key: SoundTest.fromJson(entry.key, entry.value)
      };
    } catch (e) {
      print('Error parsing sound tests: $e');
      return {};
    }
  }

  Future<void> saveAllSoundTests(Map<String, SoundTest> soundTests) async {

    final prefs = await _sharedPreferences;
    final Map<String, dynamic> jsonMap = {};

    soundTests.forEach((key, soundTest) {
      jsonMap[key] = soundTest.toJson();
    });

    await prefs.setString(_soundTestsKey, jsonEncode(jsonMap));
  }

  Future<void> addSoundTest(SoundTest soundTest) async {
    final soundTests = await getAllSoundTests();
    soundTests[soundTest.id] = soundTest;
    await saveAllSoundTests(soundTests);
  }

  Future<void> updateSoundTest(SoundTest soundTest) async {
    await addSoundTest(soundTest); // Same implementation as add
  }

  Future<void> deleteSoundTest(String id) async {
    final soundTests = await getAllSoundTests();
    soundTests.remove(id);
    await saveAllSoundTests(soundTests);
  }
}
