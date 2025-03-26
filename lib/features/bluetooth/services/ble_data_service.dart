import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../platform/bluetooth_platform.dart';
import '../../sound_test/models/sound_test.dart';
import '../../presets/models/preset.dart';

class BLEDataService {
  // Method channel for BLE data transmission
  static const platform = MethodChannel('com.headphonemobileapp/ble_data');

  // UUIDs for characteristics
  static const String HEARING_TEST_CHAR_UUID =
      "00002A1C-0000-1000-8000-00805f9b34fb"; // Baseline hearing characteristic
  static const String PRESET_CHAR_UUID =
      "00002A1D-0000-1000-8000-00805f9b34fb"; // Preset settings characteristic
  static const String COMBINED_DATA_CHAR_UUID =
      "00002A1E-0000-1000-8000-00805f9b34fb"; // Combined data characteristic

  // Maximum size for BLE transmission (MTU size - overhead)
  static const int MAX_CHUNK_SIZE = 512;

  // Send hearing test data over BLE
  Future<bool> sendHearingTestData(SoundTest soundTest) async {
    try {
      // Convert to JSON
      Map<String, dynamic> jsonData = soundTest.toJson();
      jsonData['id'] = soundTest.id; // Add ID which may not be in toJson()

      // Send data
      return await _sendJSONData(HEARING_TEST_CHAR_UUID, jsonData);
    } catch (e) {
      print("Failed to send hearing test data: $e");
      return false;
    }
  }

  // Send preset data over BLE
  Future<bool> sendPresetData(Preset preset) async {
    try {
      // Convert to JSON
      Map<String, dynamic> jsonData = preset.toJson();
      jsonData['id'] = preset.id; // Add ID which may not be in toJson()

      // Send data
      return await _sendJSONData(PRESET_CHAR_UUID, jsonData);
    } catch (e) {
      print("Failed to send preset data: $e");
      return false;
    }
  }

  // Send combined hearing test and preset data
  Future<bool> sendCombinedData(SoundTest soundTest, Preset preset) async {
    try {
      // Create combined data
      Map<String, dynamic> combinedData =
          calculateCombinedValues(soundTest, preset);

      // Send data
      return await _sendJSONData(COMBINED_DATA_CHAR_UUID, combinedData);
    } catch (e) {
      print("Failed to send combined data: $e");
      return false;
    }
  }

  // Calculate combined values from hearing test and preset
  Map<String, dynamic> calculateCombinedValues(
      SoundTest soundTest, Preset preset) {
    // Get the original data
    Map<String, double> hearingData = Map.from(soundTest.soundTestData);
    Map<String, dynamic> presetData = preset.presetData;

    // Create a new map for the combined values
    Map<String, dynamic> combinedData = {
      'hearingTest': soundTest.toJson(),
      'preset': preset.toJson(),
      'combinedValues': <String, dynamic>{},
      'hearingTestId': soundTest.id,
      'presetId': preset.id,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Apply preset EQ adjustments to hearing test values
    Map<String, double> adjustedHearing = {};

    // Extract preset values
    double overallVolume = presetData['db_valueOV'] ?? 0.0;
    double bassAdjustment = presetData['db_valueSB_BS'] ?? 0.0;
    double midAdjustment = presetData['db_valueSB_MRS'] ?? 0.0;
    double trebleAdjustment = presetData['db_valueSB_TS'] ?? 0.0;
    bool reduceBackgroundNoise = presetData['reduce_background_noise'] ?? false;
    bool reduceWindNoise = presetData['reduce_wind_noise'] ?? false;
    bool softenSuddenNoise = presetData['soften_sudden_noise'] ?? false;

    // Map frequencies to band adjustments (simplified approach)
    // Bass affects 250-500Hz, Mids affect 1000Hz, Treble affects 2000-4000Hz
    adjustedHearing['L_user_250Hz_dB'] =
        (hearingData['L_user_250Hz_dB'] ?? 0.0) +
            bassAdjustment +
            overallVolume;
    adjustedHearing['R_user_250Hz_dB'] =
        (hearingData['R_user_250Hz_dB'] ?? 0.0) +
            bassAdjustment +
            overallVolume;

    adjustedHearing['L_user_500Hz_dB'] =
        (hearingData['L_user_500Hz_dB'] ?? 0.0) +
            bassAdjustment * 0.8 +
            overallVolume;
    adjustedHearing['R_user_500Hz_dB'] =
        (hearingData['R_user_500Hz_dB'] ?? 0.0) +
            bassAdjustment * 0.8 +
            overallVolume;

    adjustedHearing['L_user_1000Hz_dB'] =
        (hearingData['L_user_1000Hz_dB'] ?? 0.0) +
            midAdjustment +
            overallVolume;
    adjustedHearing['R_user_1000Hz_dB'] =
        (hearingData['R_user_1000Hz_dB'] ?? 0.0) +
            midAdjustment +
            overallVolume;

    adjustedHearing['L_user_2000Hz_dB'] =
        (hearingData['L_user_2000Hz_dB'] ?? 0.0) +
            trebleAdjustment * 0.7 +
            overallVolume;
    adjustedHearing['R_user_2000Hz_dB'] =
        (hearingData['R_user_2000Hz_dB'] ?? 0.0) +
            trebleAdjustment * 0.7 +
            overallVolume;

    adjustedHearing['L_user_4000Hz_dB'] =
        (hearingData['L_user_4000Hz_dB'] ?? 0.0) +
            trebleAdjustment +
            overallVolume;
    adjustedHearing['R_user_4000Hz_dB'] =
        (hearingData['R_user_4000Hz_dB'] ?? 0.0) +
            trebleAdjustment +
            overallVolume;

    // Add the adjusted hearing values
    combinedData['combinedValues'] = {
      'adjustedHearing': adjustedHearing,
      'noiseReduction': {
        'reduceBackgroundNoise': reduceBackgroundNoise,
        'reduceWindNoise': reduceWindNoise,
        'softenSuddenNoise': softenSuddenNoise,
      }
    };

    return combinedData;
  }

  // Helper method to send JSON data over BLE
  Future<bool> _sendJSONData(
      String characteristicUuid, Map<String, dynamic> data) async {
    try {
      // Convert to JSON string
      String jsonString = jsonEncode(data);

      // Convert to bytes
      List<int> bytes = utf8.encode(jsonString);

      // Check if we need to split into chunks
      if (bytes.length <= MAX_CHUNK_SIZE) {
        // Send in one go
        return await _writeCharacteristic(
            characteristicUuid, Uint8List.fromList(bytes), false);
      } else {
        // Send in chunks with metadata
        int totalChunks = (bytes.length / MAX_CHUNK_SIZE).ceil();
        bool success = true;

        for (int i = 0; i < totalChunks; i++) {
          int start = i * MAX_CHUNK_SIZE;
          int end = (start + MAX_CHUNK_SIZE < bytes.length)
              ? start + MAX_CHUNK_SIZE
              : bytes.length;

          // Add chunk metadata
          List<int> chunkMetadata = [
            i, // chunk index
            totalChunks - 1, // last chunk index
          ];

          // Create chunk with metadata
          List<int> chunk = [...chunkMetadata, ...bytes.sublist(start, end)];

          // Send chunk
          bool chunkSent = await _writeCharacteristic(
            characteristicUuid,
            Uint8List.fromList(chunk),
            i < totalChunks - 1, // Only wait for response on last chunk
          );

          if (!chunkSent) {
            success = false;
            break;
          }
        }

        return success;
      }
    } catch (e) {
      print("Error sending JSON data: $e");
      return false;
    }
  }

  // Write to BLE characteristic
  Future<bool> _writeCharacteristic(
      String characteristicUuid, Uint8List data, bool withoutResponse) async {
    try {
      return await platform.invokeMethod('writeCharacteristic', {
        'characteristicUuid': characteristicUuid,
        'data': data,
        'withoutResponse': withoutResponse,
      });
    } on PlatformException catch (e) {
      print("Failed to write characteristic: ${e.message}");
      return false;
    }
  }

  // Helper method to check if connection is ready for data transmission
  Future<bool> isReadyForTransmission() async {
    try {
      // Check if we have a connected device
      final isConnected = await BluetoothPlatform.isAudioDeviceConnected();
      if (!isConnected) {
        return false;
      }

      // Check if service and characteristics are available
      return await platform.invokeMethod('isGattReady');
    } on PlatformException catch (e) {
      print("Failed to check GATT readiness: ${e.message}");
      return false;
    }
  }
}
