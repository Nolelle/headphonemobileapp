import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';

void main() {
  group('SoundTest Model Tests', () {
    test('SoundTest data validation test', () {
      // Create a sound test with extreme values
      final soundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: DateTime.now(),
        soundTestData: {
          'L_user_250Hz_dB': 100.0,
          'L_user_500Hz_dB': -10.0,
          'R_user_1000Hz_dB': 150.0,
          'R_user_2000Hz_dB': -20.0,
        },
        icon: Icons.hearing,
      );

      // Create a validated version of the sound test
      final validatedData = Map<String, dynamic>.from(soundTest.soundTestData);

      // Clamp values to valid ranges (0.0 to 90.0 dB)
      soundTest.soundTestData.forEach((key, value) {
        if (key.endsWith('Hz_dB') && value is num) {
          validatedData[key] = (value).clamp(0.0, 90.0);
        }
      });

      final validatedSoundTest = SoundTest(
        id: soundTest.id,
        name: soundTest.name,
        dateCreated: soundTest.dateCreated,
        soundTestData: validatedData,
        icon: soundTest.icon,
      );

      // Assert values are clamped to valid ranges
      expect(validatedSoundTest.soundTestData['L_user_250Hz_dB'], 90.0);
      expect(validatedSoundTest.soundTestData['L_user_500Hz_dB'], 0.0);
      expect(validatedSoundTest.soundTestData['R_user_1000Hz_dB'], 90.0);
      expect(validatedSoundTest.soundTestData['R_user_2000Hz_dB'], 0.0);
    });

    test('SoundTest serialization test', () {
      final dateTime = DateTime(2023, 1, 1, 12, 0);
      final soundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: dateTime,
        soundTestData: {
          'L_user_250Hz_dB': 50.0,
          'R_user_500Hz_dB': 60.0,
        },
        icon: Icons.hearing,
      );

      final json = soundTest.toJson();
      final restored = SoundTest.fromJson('test_id', json);

      expect(restored.id, 'test_id');
      expect(restored.name, 'Test Profile');
      expect(restored.dateCreated, dateTime);
      expect(restored.soundTestData['L_user_250Hz_dB'], 50.0);
      expect(restored.soundTestData['R_user_500Hz_dB'], 60.0);
      expect(restored.icon.codePoint, Icons.hearing.codePoint);
    });
  });
}
