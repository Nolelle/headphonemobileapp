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
          soundTestData: {'db_valueOV': 0.0},
          icon: Icons.music_note,
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

    test('createSoundTest should call repository and update state on success',
        () async {
      // Arrange
      final testSoundTest = SoundTest(
        id: 'new',
        name: 'New Sound Test',
        dateCreated: DateTime(2024, 3, 15),
        soundTestData: {'db_valueOV': 5.0},
      );

      final updatedSoundTests = {
        'new': testSoundTest,
      };

      when(mockRepository.addSoundTest(testSoundTest)).thenAnswer((_) async {});

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
        soundTestData: {'db_valueOV': 7.5},
      );

      final updatedSoundTests = {
        'test1': updatedSoundTest,
      };

      when(mockRepository.updateSoundTest(updatedSoundTest))
          .thenAnswer((_) async {});

      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => updatedSoundTests);

      // Act
      await provider.updateSoundTest(updatedSoundTest);

      // Assert
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.soundTests, equals(updatedSoundTests));
      verify(mockRepository.updateSoundTest(updatedSoundTest)).called(1);
      verify(mockRepository.getAllSoundTests()).called(1);
    });

    test('deleteSoundTest should call repository and update state on success',
        () async {
      // Arrange
      const testId = 'test1';
      final emptyMap = <String, SoundTest>{};

      // Set an active sound test to ensure it gets cleared
      provider.setActiveSoundTest(testId);

      when(mockRepository.deleteSoundTest(testId)).thenAnswer((_) async {});

      when(mockRepository.getAllSoundTests()).thenAnswer((_) async => emptyMap);

      // Act
      await provider.deleteSoundTest(testId);

      // Assert
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.soundTests, isEmpty);
      expect(provider.activeSoundTestId, isNull);
      verify(mockRepository.deleteSoundTest(testId)).called(1);
      verify(mockRepository.getAllSoundTests()).called(1);
    });

    test('setActiveSoundTest should update the active sound test ID', () async {
      // Arrange
      final testSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound Test 1',
          dateCreated: DateTime(2024, 3, 10),
          soundTestData: {'db_valueOV': 0.0},
        ),
      };

      // Mock repository to return test sound tests
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => testSoundTests);

      // Load sound tests into provider
      await provider.fetchSoundTests();

      // Act
      provider.setActiveSoundTest('test1');

      // Assert
      expect(provider.activeSoundTestId, equals('test1'));
      expect(provider.activeSoundTest, equals(testSoundTests['test1']));
    });

    test('clearActiveSoundTest should set active sound test ID to null',
        () async {
      // Arrange - Set an active sound test
      final testSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound Test 1',
          dateCreated: DateTime(2024, 3, 10),
          soundTestData: {'db_valueOV': 0.0},
        ),
      };

      // Mock repository to return test sound tests
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => testSoundTests);

      // Load sound tests into provider and set active
      await provider.fetchSoundTests();
      provider.setActiveSoundTest('test1');
      expect(provider.activeSoundTestId, equals('test1'));

      // Act
      provider.clearActiveSoundTest();

      // Assert
      expect(provider.activeSoundTestId, isNull);
      expect(provider.activeSoundTest, isNull);
    });

    test('getSoundTestById should return correct sound test', () async {
      // Arrange
      final testSoundTest = SoundTest(
        id: 'test1',
        name: 'Test Sound Test 1',
        dateCreated: DateTime(2024, 3, 10),
        soundTestData: {'db_valueOV': 0.0},
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
