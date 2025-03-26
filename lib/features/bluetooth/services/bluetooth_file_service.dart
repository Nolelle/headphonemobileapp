import 'dart:convert';
import 'package:flutter/services.dart';
import '../../sound_test/models/sound_test.dart';

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
}
