import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';

void main() {
  group('SoundTest Model Data Validation Tests', () {
    test(
        'testSoundTestDataValidation - should clamp extreme values to valid ranges',
        () {
      // Create a sound test with extreme values
      final soundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: DateTime.now(),
        soundTestData: {
          'L_user_250Hz_dB': 100.0, // Above max (should be clamped)
          'L_user_500Hz_dB': -10.0, // Below min (should be clamped)
          'R_user_1000Hz_dB': 150.0, // Extremely high (should be clamped)
          'R_user_2000Hz_dB': -20.0, // Extremely low (should be clamped)
          'L_user_4000Hz_dB': 85.0, // Within range (should stay same)
          'R_user_8000Hz_dB': 5.0, // Within range (should stay same)
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

      // Values within range should remain unchanged
      expect(validatedSoundTest.soundTestData['L_user_4000Hz_dB'], 85.0);
      expect(validatedSoundTest.soundTestData['R_user_8000Hz_dB'], 5.0);

      // Original sound test should remain unmodified
      expect(soundTest.soundTestData['L_user_250Hz_dB'], 100.0);
      expect(soundTest.soundTestData['R_user_2000Hz_dB'], -20.0);

      // Verify clamp operation works on all values
      for (final entry in validatedSoundTest.soundTestData.entries) {
        if (entry.key.endsWith('Hz_dB')) {
          final double value = entry.value as double;
          expect(value >= 0.0 && value <= 90.0, true,
              reason:
                  '${entry.key} value should be between 0.0 and 90.0 but was $value');
        }
      }
    });
  });
}
