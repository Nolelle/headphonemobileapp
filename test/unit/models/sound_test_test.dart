import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';

void main() {
  group('SoundTest Model Tests', () {
    test('SoundTest creates with valid data', () {
      final testTime = DateTime.now();
      final soundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: testTime,
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
        },
        icon: Icons.hearing,
      );

      expect(soundTest.id, 'test_id');
      expect(soundTest.name, 'Test Profile');
      expect(soundTest.dateCreated, testTime);
      expect(soundTest.soundTestData['L_user_250Hz_dB'], 50.0);
      expect(soundTest.soundTestData['R_user_4000Hz_dB'], 65.0);
      expect(soundTest.icon, Icons.hearing);
    });

    test('SoundTest.defaultTest should create test with baseline values', () {
      final defaultTest = SoundTest.defaultTest('default_id');

      // Check that all required frequencies exist with baseline value
      const baselineValue = -10.0;
      expect(defaultTest.id, 'default_id');
      expect(defaultTest.name, 'Default Audio Profile');
      expect(defaultTest.soundTestData['L_user_250Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['L_user_500Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['L_user_1000Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['L_user_2000Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['L_user_4000Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['R_user_250Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['R_user_500Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['R_user_1000Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['R_user_2000Hz_dB'], baselineValue);
      expect(defaultTest.soundTestData['R_user_4000Hz_dB'], baselineValue);
      expect(defaultTest.icon, Icons.hearing);
    });

    test('SoundTest serialization and deserialization test', () {
      final dateTime = DateTime(2023, 1, 1, 12, 0);
      final soundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: dateTime,
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
        },
        icon: Icons.hearing,
      );

      final json = soundTest.toJson();
      final restored = SoundTest.fromJson('test_id', json);

      expect(restored.id, 'test_id');
      expect(restored.name, 'Test Profile');
      expect(restored.dateCreated, dateTime);
      expect(restored.soundTestData['L_user_250Hz_dB'], 50.0);
      expect(restored.soundTestData['L_user_500Hz_dB'], 55.0);
      expect(restored.soundTestData['L_user_1000Hz_dB'], 60.0);
      expect(restored.soundTestData['L_user_2000Hz_dB'], 65.0);
      expect(restored.soundTestData['L_user_4000Hz_dB'], 70.0);
      expect(restored.soundTestData['R_user_250Hz_dB'], 45.0);
      expect(restored.soundTestData['R_user_500Hz_dB'], 50.0);
      expect(restored.soundTestData['R_user_1000Hz_dB'], 55.0);
      expect(restored.soundTestData['R_user_2000Hz_dB'], 60.0);
      expect(restored.soundTestData['R_user_4000Hz_dB'], 65.0);
      expect(restored.icon?.codePoint, Icons.hearing.codePoint);
    });

    test('SoundTest.fromJson handles missing data with defaults', () {
      final dateTime = DateTime(2023, 1, 1, 12, 0);
      final incompleteJson = {
        'name': 'Incomplete Profile',
        'dateCreated': dateTime.toIso8601String(),
        'soundTestData': {
          'L_user_250Hz_dB': 50.0,
          // Other frequencies missing
        },
      };

      final restored = SoundTest.fromJson('test_id', incompleteJson);

      expect(restored.id, 'test_id');
      expect(restored.name, 'Incomplete Profile');
      expect(restored.dateCreated, dateTime);
      expect(restored.soundTestData['L_user_250Hz_dB'], 50.0);
      // Check that missing values default to -10.0
      expect(restored.soundTestData['L_user_500Hz_dB'], -10.0);
      expect(restored.soundTestData['L_user_1000Hz_dB'], -10.0);
      expect(restored.soundTestData['L_user_2000Hz_dB'], -10.0);
      expect(restored.soundTestData['L_user_4000Hz_dB'], -10.0);
      expect(restored.soundTestData['R_user_250Hz_dB'], -10.0);
      expect(restored.soundTestData['R_user_500Hz_dB'], -10.0);
      expect(restored.soundTestData['R_user_1000Hz_dB'], -10.0);
      expect(restored.soundTestData['R_user_2000Hz_dB'], -10.0);
      expect(restored.soundTestData['R_user_4000Hz_dB'], -10.0);
    });
  });
}
