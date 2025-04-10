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
  group('SoundTestRepository Save Tests', () {
    late MockSharedPreferences mockPrefs;
    late SoundTestRepository repository;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      repository = SoundTestRepository(sharedPreferences: mockPrefs);
    });

    test('saveAllSoundTests should properly serialize all tests', () async {
      // Arrange
      final testTime = DateTime.now();
      final soundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Profile 1',
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
        ),
        'test2': SoundTest(
          id: 'test2',
          name: 'Test Profile 2',
          dateCreated: testTime.add(const Duration(days: 1)),
          soundTestData: {
            'L_user_250Hz_dB': 40.0,
            'L_user_500Hz_dB': 45.0,
            'L_user_1000Hz_dB': 50.0,
            'L_user_2000Hz_dB': 55.0,
            'L_user_4000Hz_dB': 60.0,
            'R_user_250Hz_dB': 35.0,
            'R_user_500Hz_dB': 40.0,
            'R_user_1000Hz_dB': 45.0,
            'R_user_2000Hz_dB': 50.0,
            'R_user_4000Hz_dB': 55.0,
          },
          icon: Icons.hearing,
        ),
      };

      // Mock successful save
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      // Act
      await repository.saveAllSoundTests(soundTests);

      // Assert
      verify(mockPrefs.setString('soundTestsMap', argThat(
        predicate<String>((jsonStr) {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);

          // Check if both test IDs exist
          if (!jsonMap.containsKey('test1') || !jsonMap.containsKey('test2')) {
            return false;
          }

          // Check a few values from each test
          final test1Data = jsonMap['test1']['soundTestData'];
          final test2Data = jsonMap['test2']['soundTestData'];

          return test1Data['L_user_250Hz_dB'] == 50.0 &&
              test1Data['R_user_4000Hz_dB'] == 65.0 &&
              test2Data['L_user_250Hz_dB'] == 40.0 &&
              test2Data['R_user_4000Hz_dB'] == 55.0;
        }),
      ))).called(1);
    });

    test('addSoundTest should add a single test to existing tests', () async {
      // Arrange
      final testTime = DateTime.now();

      // Create existing sound tests
      final existingJson = {
        'existing1': {
          'name': 'Existing Test 1',
          'dateCreated': testTime.toIso8601String(),
          'soundTestData': {
            'L_user_250Hz_dB': 10.0,
            'L_user_500Hz_dB': 10.0,
            'L_user_1000Hz_dB': 10.0,
            'L_user_2000Hz_dB': 10.0,
            'L_user_4000Hz_dB': 10.0,
            'R_user_250Hz_dB': 10.0,
            'R_user_500Hz_dB': 10.0,
            'R_user_1000Hz_dB': 10.0,
            'R_user_2000Hz_dB': 10.0,
            'R_user_4000Hz_dB': 10.0,
          }
        }
      };

      // Create new sound test
      final newSoundTest = SoundTest(
        id: 'new1',
        name: 'New Test 1',
        dateCreated: testTime.add(const Duration(days: 1)),
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

      // Mock retrieval of existing tests
      when(mockPrefs.getString('soundTestsMap'))
          .thenReturn(jsonEncode(existingJson));

      // Mock successful save
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      // Act
      await repository.addSoundTest(newSoundTest);

      // Assert
      verify(mockPrefs.setString('soundTestsMap', argThat(
        predicate<String>((jsonStr) {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);

          // Both existing and new tests should be present
          if (!jsonMap.containsKey('existing1') ||
              !jsonMap.containsKey('new1')) {
            return false;
          }

          // Check values from new test
          final newTestData = jsonMap['new1']['soundTestData'];
          return newTestData['L_user_250Hz_dB'] == 50.0 &&
              newTestData['L_user_500Hz_dB'] == 55.0 &&
              newTestData['L_user_1000Hz_dB'] == 60.0 &&
              newTestData['L_user_2000Hz_dB'] == 65.0 &&
              newTestData['L_user_4000Hz_dB'] == 70.0 &&
              newTestData['R_user_250Hz_dB'] == 45.0 &&
              newTestData['R_user_500Hz_dB'] == 50.0 &&
              newTestData['R_user_1000Hz_dB'] == 55.0 &&
              newTestData['R_user_2000Hz_dB'] == 60.0 &&
              newTestData['R_user_4000Hz_dB'] == 65.0;
        }),
      ))).called(1);
    });
  });
}
