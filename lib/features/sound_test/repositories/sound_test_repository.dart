import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/sound_test.dart';

class SoundTestRepository {
  static const String _soundTestsKey = 'soundTestsMap';

  Future<Map<String, SoundTest>> getAllSoundTests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_soundTestsKey);

    if (jsonString == null) {
      return {};
    }

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final Map<String, SoundTest> soundTests = {};

      jsonMap.forEach((key, value) {
        soundTests[key] = SoundTest.fromJson(key, value);
      });

      return soundTests;
    } catch (e) {
      print('Error parsing sound tests: $e');
      return {};
    }
  }

  Future<void> saveAllSoundTests(Map<String, SoundTest> soundTests) async {
    final prefs = await SharedPreferences.getInstance();
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
    final soundTests = await getAllSoundTests();
    soundTests[soundTest.id] = soundTest;
    await saveAllSoundTests(soundTests);
  }

  Future<void> deleteSoundTest(String id) async {
    final soundTests = await getAllSoundTests();
    soundTests.remove(id);
    await saveAllSoundTests(soundTests);
  }
}