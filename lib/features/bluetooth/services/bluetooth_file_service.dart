import 'dart:convert';
import 'package:flutter/services.dart';
import '../../sound_test/models/sound_test.dart';
import '../../presets/models/preset.dart';

class BluetoothFileService {
  // Method channel for Bluetooth file transfer
  static const platform = MethodChannel('com.headphonemobileapp/bt_file');

  // Send hearing test data as a file via Bluetooth
  Future<bool> sendHearingTestFile(SoundTest soundTest) async {
    try {
      // Convert to JSON
      Map<String, dynamic> jsonData = soundTest.toJson();
      jsonData['id'] = soundTest.id; // Add ID which may not be in toJson()

      // Generate timestamp for the filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'hearing_test_$timestamp.json';

      // Convert the data to a JSON string
      final jsonString = jsonEncode(jsonData);

      // Send the file via the platform channel
      return await platform.invokeMethod('sendFile', {
        'jsonData': jsonString,
        'fileName': fileName,
      });
    } catch (e) {
      print("Failed to send hearing test file: $e");
      return false;
    }
  }

  // Send preset data as a file via Bluetooth
  Future<bool> sendPresetFile(Preset preset) async {
    try {
      // Convert to JSON
      Map<String, dynamic> jsonData = preset.toJson();
      jsonData['id'] = preset.id; // Add ID which may not be in toJson()

      // Generate timestamp for the filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'preset_${preset.name.replaceAll(' ', '_')}_$timestamp.json';

      // Convert the data to a JSON string
      final jsonString = jsonEncode(jsonData);

      // Send the file via the platform channel
      return await platform.invokeMethod('sendFile', {
        'jsonData': jsonString,
        'fileName': fileName,
      });
    } catch (e) {
      print("Failed to send preset file: $e");
      return false;
    }
  }

  // Apply preset settings to hearing test data and send combined file
  Future<bool> sendCombinedHearingTestWithPreset(
      SoundTest soundTest, Preset preset) async {
    try {
      // Create a copy of the original hearing test data to modify
      Map<String, dynamic> jsonData = {};

      // Set fields in the requested order
      jsonData['id'] = soundTest.id;
      jsonData['dateCreated'] = soundTest.dateCreated.toIso8601String();
      jsonData['name'] = soundTest.name;

      // Get preset data values
      final bassAdjustment = preset.presetData['db_valueSB_BS'] as double;
      final midAdjustment = preset.presetData['db_valueSB_MRS'] as double;
      final trebleAdjustment = preset.presetData['db_valueSB_TS'] as double;
      final overallVolume = preset.presetData['db_valueOV'] as double;

      // Clone the sound test data for modifications
      Map<String, dynamic> soundTestData =
          Map<String, dynamic>.from(soundTest.toJson()['soundTestData'] as Map);

      // Apply frequency-based adjustments to both ears
      // Bass adjustment (250Hz, 500Hz)
      _applyAdjustment(
          soundTestData, 'L_user_250Hz_dB', bassAdjustment + overallVolume);
      _applyAdjustment(
          soundTestData, 'R_user_250Hz_dB', bassAdjustment + overallVolume);
      _applyAdjustment(
          soundTestData, 'L_user_500Hz_dB', bassAdjustment + overallVolume);
      _applyAdjustment(
          soundTestData, 'R_user_500Hz_dB', bassAdjustment + overallVolume);

      // Mid adjustment (1000Hz, 2000Hz)
      _applyAdjustment(
          soundTestData, 'L_user_1000Hz_dB', midAdjustment + overallVolume);
      _applyAdjustment(
          soundTestData, 'R_user_1000Hz_dB', midAdjustment + overallVolume);
      _applyAdjustment(
          soundTestData, 'L_user_2000Hz_dB', midAdjustment + overallVolume);
      _applyAdjustment(
          soundTestData, 'R_user_2000Hz_dB', midAdjustment + overallVolume);

      // Treble adjustment (4000Hz)
      _applyAdjustment(
          soundTestData, 'L_user_4000Hz_dB', trebleAdjustment + overallVolume);
      _applyAdjustment(
          soundTestData, 'R_user_4000Hz_dB', trebleAdjustment + overallVolume);

      // Add the sound test data
      jsonData['soundTestData'] = soundTestData;

      // Add the preset enhancement settings
      jsonData['presetEnhancements'] = {
        'presetId': preset.id,
        'presetName': preset.name,
        'overallVolume': preset.presetData['db_valueOV'],
        'bassAdjustment': preset.presetData['db_valueSB_BS'],
        'midAdjustment': preset.presetData['db_valueSB_MRS'],
        'trebleAdjustment': preset.presetData['db_valueSB_TS'],
        'reduce_background_noise': preset.presetData['reduce_background_noise'],
        'reduce_wind_noise': preset.presetData['reduce_wind_noise'],
        'soften_sudden_noise': preset.presetData['soften_sudden_noise'],
      };

      // Create descriptive filename combining both
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'hearing_profile_with_${preset.name.replaceAll(' ', '_')}_$timestamp.json';

      // Convert the data to a JSON string
      final jsonString = jsonEncode(jsonData);

      // Send the file via the platform channel
      return await platform.invokeMethod('sendFile', {
        'jsonData': jsonString,
        'fileName': fileName,
      });
    } catch (e) {
      print("Failed to send combined hearing test with preset: $e");
      return false;
    }
  }

  // Helper method to apply adjustments to sound test data values
  void _applyAdjustment(
      Map<String, dynamic> soundTestData, String key, double adjustment) {
    if (soundTestData.containsKey(key)) {
      // Apply adjustment but ensure we have reasonable limits
      // Remember lower values = better hearing in the model
      double currentValue = (soundTestData[key] as num).toDouble();
      double newValue =
          currentValue - adjustment; // Subtract because of how the scale works

      // Ensure values stay within a reasonable range (-40 to 80 dB range in the model)
      if (newValue < -40.0) newValue = -40.0;
      if (newValue > 80.0) newValue = 80.0;

      soundTestData[key] = newValue;
    }
  }
}
