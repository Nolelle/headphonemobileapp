import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/preset.dart';

class PresetRepository {
  static const String _presetsKey = 'presetsMap';

  Future<Map<String, Preset>> getAllPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_presetsKey);

    if (jsonString == null) {
      return {};
    }

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final Map<String, Preset> presets = {};

      jsonMap.forEach((key, value) {
        presets[key] = Preset.fromJson(key, value);
      });

      return presets;
    } catch (e) {
      print('Error parsing presets: $e');
      return {};
    }
  }

  Future<void> saveAllPresets(Map<String, Preset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonMap = {};

    presets.forEach((key, preset) {
      jsonMap[key] = preset.toJson();
    });

    await prefs.setString(_presetsKey, jsonEncode(jsonMap));
  }

  Future<void> addPreset(Preset preset) async {
    final presets = await getAllPresets();
    presets[preset.id] = preset;
    await saveAllPresets(presets);
  }

  Future<void> updatePreset(Preset preset) async {
    final presets = await getAllPresets();
    presets[preset.id] = preset;
    await saveAllPresets(presets);
  }

  Future<void> deletePreset(String id) async {
    final presets = await getAllPresets();
    presets.remove(id);
    await saveAllPresets(presets);
  }
}
