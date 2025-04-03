import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';

@GenerateMocks([SoundTestRepository])
import 'sound_test_provider_test.mocks.dart';

void main() {
  group('SoundTestProvider Tests', () {
    late MockSoundTestRepository mockRepository;
    late SoundTestProvider provider;

    setUp(() {
      mockRepository = MockSoundTestRepository();
      provider = SoundTestProvider(mockRepository);
    });

    test('initial state should be empty with no errors', () {
      expect(provider.soundTests, isEmpty);
      expect(provider.activeSoundTestId, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('fetchSoundTests should update state correctly on success', () async {
      // Arrange
      final testSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound Test 1',
          dateCreated: DateTime(2024, 3, 10),
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
      };

      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => testSoundTests);

      // Act
      await provider.fetchSoundTests();

      // Assert
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.soundTests, equals(testSoundTests));
      expect(provider.activeSoundTestId, equals('test1'));
      verify(mockRepository.getAllSoundTests()).called(1);
    });

    test('fetchSoundTests should handle errors properly', () async {
      // Arrange
      final testException = Exception('Test error');
      when(mockRepository.getAllSoundTests()).thenThrow(testException);

      // Act
      await provider.fetchSoundTests();

      // Assert
      expect(provider.isLoading, isFalse);
      expect(provider.error, contains('Failed to load sound tests'));
      expect(provider.soundTests, isEmpty);
      verify(mockRepository.getAllSoundTests()).called(1);
    });

    test('fetchSoundTests should keep only the most recent profile', () async {
      // Arrange
      final oldTest = SoundTest(
        id: 'old',
        name: 'Old Test',
        dateCreated: DateTime(2024, 1, 1),
        soundTestData: createStandardTestData(30.0),
      );

      final recentTest = SoundTest(
        id: 'recent',
        name: 'Recent Test',
        dateCreated: DateTime(2024, 3, 15),
        soundTestData: createStandardTestData(40.0),
      );

      final testSoundTests = {
        'old': oldTest,
        'recent': recentTest,
      };

      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => testSoundTests);
      when(mockRepository.deleteSoundTest(any)).thenAnswer((_) async {});

      // Act
      await provider.fetchSoundTests();

      // Assert
      expect(provider.soundTests.length, 1);
      expect(provider.soundTests.containsKey('recent'), isTrue);
      expect(provider.soundTests.containsKey('old'), isFalse);
      expect(provider.activeSoundTestId, 'recent');
      verify(mockRepository.deleteSoundTest('old')).called(1);
    });

    test('createSoundTest should call repository and update state on success',
        () async {
      // Arrange
      final testSoundTest = SoundTest(
        id: 'new',
        name: 'New Sound Test',
        dateCreated: DateTime(2024, 3, 15),
        soundTestData: createStandardTestData(50.0),
      );

      final updatedSoundTests = {
        'new': testSoundTest,
      };

      when(mockRepository.addSoundTest(testSoundTest)).thenAnswer((_) async {});

      // The test emulates that fetchSoundTests is called inside createSoundTest
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => updatedSoundTests);

      // Act
      await provider.createSoundTest(testSoundTest);

      // Assert
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.soundTests, equals(updatedSoundTests));
      verify(mockRepository.addSoundTest(testSoundTest)).called(1);
      verify(mockRepository.getAllSoundTests()).called(1);
    });

    test('updateSoundTest should call repository and update state on success',
        () async {
      // Arrange
      final updatedSoundTest = SoundTest(
        id: 'test1',
        name: 'Updated Sound Test',
        dateCreated: DateTime(2024, 3, 15),
        soundTestData: createStandardTestData(60.0),
      );

      when(mockRepository.updateSoundTest(updatedSoundTest))
          .thenAnswer((_) async {});

      // Act
      await provider.updateSoundTest(updatedSoundTest);

      // Assert
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.soundTests['test1'], equals(updatedSoundTest));
      expect(provider.activeSoundTestId, equals('test1'));
      verify(mockRepository.updateSoundTest(updatedSoundTest)).called(1);
    });

    test('resetSoundTest should replace test with defaults', () async {
      // Arrange
      const testId = 'test1';
      final defaultTest = SoundTest.defaultTest(testId);

      when(mockRepository.updateSoundTest(any)).thenAnswer((_) async {});

      // Act
      await provider.resetSoundTest(testId);

      // Assert
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      // Can't directly compare the objects because the creation dates might differ
      expect(provider.soundTests[testId]?.id, equals(testId));
      verify(mockRepository.updateSoundTest(any)).called(1);
    });

    test('getSoundTestById should return correct sound test', () async {
      // Arrange
      final testSoundTest = SoundTest(
        id: 'test1',
        name: 'Test Sound Test 1',
        dateCreated: DateTime(2024, 3, 10),
        soundTestData: createStandardTestData(40.0),
      );

      final testSoundTests = {'test1': testSoundTest};

      // Mock repository to return test sound tests
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => testSoundTests);

      // Load sound tests into provider
      await provider.fetchSoundTests();

      // Act
      final result = provider.getSoundTestById('test1');

      // Assert
      expect(result, equals(testSoundTest));
    });

    test('clearError should clear the error state', () async {
      // Arrange - Set an error by triggering an error condition
      final testException = Exception('Test error');
      when(mockRepository.getAllSoundTests()).thenThrow(testException);

      // Create the error state
      await provider.fetchSoundTests();
      expect(provider.error, isNotNull);

      // Act
      provider.clearError();

      // Assert
      expect(provider.error, isNull);
    });
  });
}

// Helper function to create standard test data with the same value for all frequencies
Map<String, double> createStandardTestData(double value) {
  return {
    'L_user_250Hz_dB': value,
    'L_user_500Hz_dB': value,
    'L_user_1000Hz_dB': value,
    'L_user_2000Hz_dB': value,
    'L_user_4000Hz_dB': value,
    'R_user_250Hz_dB': value,
    'R_user_500Hz_dB': value,
    'R_user_1000Hz_dB': value,
    'R_user_2000Hz_dB': value,
    'R_user_4000Hz_dB': value,
  };
}
