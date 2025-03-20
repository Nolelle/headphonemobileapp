import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';

@GenerateMocks([SharedPreferences])
import 'sound_test_repository_save_test.mocks.dart';

void main() {
  group('SoundTestRepository Tests', () {
    late MockSharedPreferences mockPrefs;
    late SoundTestRepository repository;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      repository = SoundTestRepository(sharedPreferences: mockPrefs);
    });

    test('testSaveSoundTest - should save test results with all frequency data',
        () async {
      // Arrange
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
          'L_user_8000Hz_dB': 75.0,
          'R_user_250Hz_dB': 45.0,
          'R_user_500Hz_dB': 50.0,
          'R_user_1000Hz_dB': 55.0,
          'R_user_2000Hz_dB': 60.0,
          'R_user_4000Hz_dB': 65.0,
          'R_user_8000Hz_dB': 70.0,
        },
        icon: Icons.hearing,
      );

      // Mock getting empty map first
      when(mockPrefs.getString('soundTestsMap')).thenReturn(null);

      // Mock successful save
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      // Act
      await repository.addSoundTest(soundTest);

      // Assert
      // Verify setString was called once with the correct key
      verify(mockPrefs.setString('soundTestsMap', argThat(
        predicate<String>((jsonStr) {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
          // Check if the test_id key exists
          if (!jsonMap.containsKey('test_id')) {
            return false;
          }

          // Check if all frequency values are present
          final testData = jsonMap['test_id']['soundTestData'];
          return testData['L_user_250Hz_dB'] == 50.0 &&
              testData['L_user_500Hz_dB'] == 55.0 &&
              testData['L_user_1000Hz_dB'] == 60.0 &&
              testData['L_user_2000Hz_dB'] == 65.0 &&
              testData['L_user_4000Hz_dB'] == 70.0 &&
              testData['L_user_8000Hz_dB'] == 75.0 &&
              testData['R_user_250Hz_dB'] == 45.0 &&
              testData['R_user_500Hz_dB'] == 50.0 &&
              testData['R_user_1000Hz_dB'] == 55.0 &&
              testData['R_user_2000Hz_dB'] == 60.0 &&
              testData['R_user_4000Hz_dB'] == 65.0 &&
              testData['R_user_8000Hz_dB'] == 70.0;
        }),
      ))).called(1);
    });
  });
}
