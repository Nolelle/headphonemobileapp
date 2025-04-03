import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';

void main() {
  group('SoundTest Validation Tests', () {
    test('toJson should include all frequency values', () {
      final soundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: DateTime(2023, 1, 1),
        soundTestData: {
          'L_user_250Hz_dB': 50.0,
          'L_user_500Hz_dB': 55.0,
          'L_user_1000Hz_dB': 60.0,
          'L_user_2000Hz_dB': 65.0,
          'L_user_4000Hz_dB': 70.0,
          'R_user_250Hz_dB': 45.0,
          'R_user_500Hz_dB': 50.0,
          'R_user_1000Hz_dB': 55.0,
          'R_user_2000Hz_dB': 60.0,
          'R_user_4000Hz_dB': 65.0,
          'extra_field': 100.0, // Should be excluded from JSON
        },
      );

      final json = soundTest.toJson();
      final soundTestData = json['soundTestData'] as Map<String, dynamic>;

      // Check that all required frequencies are included
      expect(soundTestData['L_user_250Hz_dB'], 50.0);
      expect(soundTestData['L_user_500Hz_dB'], 55.0);
      expect(soundTestData['L_user_1000Hz_dB'], 60.0);
      expect(soundTestData['L_user_2000Hz_dB'], 65.0);
      expect(soundTestData['L_user_4000Hz_dB'], 70.0);
      expect(soundTestData['R_user_250Hz_dB'], 45.0);
      expect(soundTestData['R_user_500Hz_dB'], 50.0);
      expect(soundTestData['R_user_1000Hz_dB'], 55.0);
      expect(soundTestData['R_user_2000Hz_dB'], 60.0);
      expect(soundTestData['R_user_4000Hz_dB'], 65.0);

      // Check that extra fields are not included
      expect(soundTestData.containsKey('extra_field'), false);
    });

    test('fromJson should handle incomplete data', () {
      final json = {
        'name': 'Incomplete Profile',
        'dateCreated': DateTime(2023, 1, 1).toIso8601String(),
        'soundTestData': {
          'L_user_250Hz_dB': 50.0,
          // Missing other frequencies
        },
      };

      final soundTest = SoundTest.fromJson('test_id', json);

      // Verify default values are applied for missing frequencies
      expect(soundTest.soundTestData['L_user_250Hz_dB'], 50.0);
      expect(soundTest.soundTestData['L_user_500Hz_dB'], -10.0);
      expect(soundTest.soundTestData['L_user_1000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['L_user_2000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['L_user_4000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_250Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_500Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_1000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_2000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_4000Hz_dB'], -10.0);
    });

    test('fromJson should handle null soundTestData', () {
      final json = {
        'name': 'Null Data Profile',
        'dateCreated': DateTime(2023, 1, 1).toIso8601String(),
        'soundTestData': null,
      };

      // This should not throw an exception
      final soundTest = SoundTest.fromJson('test_id', json);

      // Verify default values are applied for all frequencies
      expect(soundTest.soundTestData['L_user_250Hz_dB'], -10.0);
      expect(soundTest.soundTestData['L_user_500Hz_dB'], -10.0);
      expect(soundTest.soundTestData['L_user_1000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['L_user_2000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['L_user_4000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_250Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_500Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_1000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_2000Hz_dB'], -10.0);
      expect(soundTest.soundTestData['R_user_4000Hz_dB'], -10.0);
    });
  });
}
