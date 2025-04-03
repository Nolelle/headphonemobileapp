import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';

@GenerateMocks([SharedPreferences])
import 'sound_test_repository_test.mocks.dart';

void main() {
  group('SoundTestRepository Tests', () {
    late MockSharedPreferences mockPrefs;
    late SoundTestRepository repository;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      repository = SoundTestRepository(sharedPreferences: mockPrefs);
    });

    test('addSoundTest should save test results with all frequency data',
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
          'R_user_250Hz_dB': 45.0,
          'R_user_500Hz_dB': 50.0,
          'R_user_1000Hz_dB': 55.0,
          'R_user_2000Hz_dB': 60.0,
          'R_user_4000Hz_dB': 65.0,
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
              testData['R_user_250Hz_dB'] == 45.0 &&
              testData['R_user_500Hz_dB'] == 50.0 &&
              testData['R_user_1000Hz_dB'] == 55.0 &&
              testData['R_user_2000Hz_dB'] == 60.0 &&
              testData['R_user_4000Hz_dB'] == 65.0;
        }),
      ))).called(1);
    });

    test('getAllSoundTests should retrieve test results correctly', () async {
      // Arrange
      final testTime = DateTime(2023, 1, 1).toIso8601String();
      final jsonString = jsonEncode({
        'test_id': {
          'name': 'Test Profile',
          'dateCreated': testTime,
          'soundTestData': {
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
          }
        }
      });

      when(mockPrefs.getString('soundTestsMap')).thenReturn(jsonString);

      // Act
      final result = await repository.getAllSoundTests();

      // Assert
      expect(result.length, 1);
      expect(result['test_id']?.name, 'Test Profile');
      expect(result['test_id']?.dateCreated, DateTime(2023, 1, 1));
      expect(result['test_id']?.soundTestData['L_user_250Hz_dB'], 50.0);
      expect(result['test_id']?.soundTestData['L_user_500Hz_dB'], 55.0);
      expect(result['test_id']?.soundTestData['L_user_1000Hz_dB'], 60.0);
      expect(result['test_id']?.soundTestData['L_user_2000Hz_dB'], 65.0);
      expect(result['test_id']?.soundTestData['L_user_4000Hz_dB'], 70.0);
      expect(result['test_id']?.soundTestData['R_user_250Hz_dB'], 45.0);
      expect(result['test_id']?.soundTestData['R_user_500Hz_dB'], 50.0);
      expect(result['test_id']?.soundTestData['R_user_1000Hz_dB'], 55.0);
      expect(result['test_id']?.soundTestData['R_user_2000Hz_dB'], 60.0);
      expect(result['test_id']?.soundTestData['R_user_4000Hz_dB'], 65.0);
    });

    test('updateSoundTest should update existing test', () async {
      // Arrange
      final testTime = DateTime.now();
      final existingTests = {
        'test_id': SoundTest(
          id: 'test_id',
          name: 'Original Profile',
          dateCreated: testTime.subtract(const Duration(days: 1)),
          soundTestData: {
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
          },
        ),
      };

      final updatedTest = SoundTest(
        id: 'test_id',
        name: 'Updated Profile',
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
      );

      // Mock initial tests
      when(mockPrefs.getString('soundTestsMap')).thenAnswer((_) => jsonEncode({
            'test_id': {
              'name': 'Original Profile',
              'dateCreated':
                  testTime.subtract(const Duration(days: 1)).toIso8601String(),
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
          }));

      // Mock successful save
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      // Act
      await repository.updateSoundTest(updatedTest);

      // Assert
      verify(mockPrefs.setString('soundTestsMap', argThat(
        predicate<String>((jsonStr) {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
          final testData = jsonMap['test_id']['soundTestData'];
          final name = jsonMap['test_id']['name'];

          return name == 'Updated Profile' &&
              testData['L_user_250Hz_dB'] == 50.0 &&
              testData['R_user_4000Hz_dB'] == 65.0;
        }),
      ))).called(1);
    });

    test('deleteSoundTest should remove test from storage', () async {
      // Arrange
      final testTime = DateTime(2023, 1, 1).toIso8601String();
      final initialJson = {
        'test_id1': {
          'name': 'Test Profile 1',
          'dateCreated': testTime,
          'soundTestData': {
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
          }
        },
        'test_id2': {
          'name': 'Test Profile 2',
          'dateCreated': testTime,
          'soundTestData': {
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
          }
        }
      };

      when(mockPrefs.getString('soundTestsMap'))
          .thenReturn(jsonEncode(initialJson));
      when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

      // Act
      await repository.deleteSoundTest('test_id1');

      // Assert
      verify(mockPrefs.setString('soundTestsMap', argThat(
        predicate<String>((jsonStr) {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
          return !jsonMap.containsKey('test_id1') &&
              jsonMap.containsKey('test_id2');
        }),
      ))).called(1);
    });
  });
}

// Helper class to modify private fields
class Reflect {
  static void setField(Object target, String fieldName, Object value) {
    // This is a stub that won't actually work in Dart
    // In a real implementation, you would either:
    // 1. Modify the SoundTestRepository to accept SharedPreferences in constructor
    // 2. Use a testing library that allows injection into private fields
    // For this test example, we're keeping this as a placeholder
  }
}
