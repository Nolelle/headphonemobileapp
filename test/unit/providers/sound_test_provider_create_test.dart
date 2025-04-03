import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';

@GenerateMocks([SoundTestRepository])
import 'sound_test_provider_create_test.mocks.dart';

void main() {
  group('SoundTestProvider Create Tests', () {
    late MockSoundTestRepository mockRepository;
    late SoundTestProvider provider;

    setUp(() {
      mockRepository = MockSoundTestRepository();
      provider = SoundTestProvider(mockRepository);
    });

    test('createSoundTest should delete existing profiles and add new one',
        () async {
      // Arrange
      final existingSoundTest = SoundTest(
        id: 'existing',
        name: 'Existing Profile',
        dateCreated: DateTime(2023, 1, 1),
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
      );

      final newSoundTest = SoundTest(
        id: 'new',
        name: 'New Profile',
        dateCreated: DateTime(2023, 2, 1),
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

      // Mock existing data
      when(mockRepository.getAllSoundTests()).thenAnswer((_) async => {
            'existing': existingSoundTest,
          });

      // Mock operations
      when(mockRepository.deleteSoundTest(any)).thenAnswer((_) async {});
      when(mockRepository.addSoundTest(any)).thenAnswer((_) async {});

      // After creating, fetchSoundTests is called which should return just the new test
      when(mockRepository.getAllSoundTests()).thenAnswer((_) async => {
            'new': newSoundTest,
          });

      // Act
      await provider.createSoundTest(newSoundTest);

      // Assert
      verify(mockRepository.deleteSoundTest('existing')).called(1);
      verify(mockRepository.addSoundTest(newSoundTest)).called(1);

      // Provider should have the new test and set it as active
      expect(provider.soundTests.length, 1);
      expect(provider.soundTests['new'], newSoundTest);
      expect(provider.activeSoundTestId, 'new');
    });

    test('createSoundTest should handle errors', () async {
      // Arrange
      final newSoundTest = SoundTest(
        id: 'new',
        name: 'New Profile',
        dateCreated: DateTime(2023, 2, 1),
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

      // Mock empty existing data
      when(mockRepository.getAllSoundTests()).thenAnswer((_) async => {});

      // Mock error during add
      when(mockRepository.addSoundTest(any))
          .thenThrow(Exception('Failed to save'));

      // Act
      await provider.createSoundTest(newSoundTest);

      // Assert
      expect(provider.error, contains('Failed to create sound test'));
      expect(provider.isLoading, isFalse);
    });
  });
}
