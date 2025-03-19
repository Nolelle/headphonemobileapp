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

    test('initial state should be empty', () {
      expect(provider.soundTests, isEmpty);
      expect(provider.activeSoundTestId, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('provider state management during operations', () async {
      // Arrange
      final validSoundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: DateTime.now(),
        soundTestData: {'L_user_250Hz_dB': 50.0},
        icon: Icons.hearing,
      );

      // Setup successful repository response
      when(mockRepository.addSoundTest(validSoundTest))
          .thenAnswer((_) async {});
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => {'test_id': validSoundTest});

      // Act - Successful operation
      // Create a state tracker for testing loading state changes
      bool wasEverLoading = false;
      listener() {
        if (provider.isLoading) {
          wasEverLoading = true;
        }
      }

      provider.addListener(listener);

      await provider.createSoundTest(validSoundTest);

      // Assert - Successful operation
      expect(wasEverLoading,
          true); // Should have been true at some point during operation
      expect(provider.isLoading, false); // Should be false after completion
      expect(provider.error, null); // Should be null after successful operation

      // Reset mock to prepare for error case
      reset(mockRepository);

      // Reset listener state
      wasEverLoading = false;
      provider.removeListener(listener);

      // Setup new listener
      provider.addListener(listener);

      // Setup error in repository
      Exception testException = Exception('Test repository error');
      when(mockRepository.addSoundTest(validSoundTest))
          .thenThrow(testException);

      // Act - Failed operation
      await provider.createSoundTest(validSoundTest);

      // Assert - Failed operation only checks that the error state is correct
      // Just verify that the method was called (not the exact count)
      verify(mockRepository.addSoundTest(any)).called(greaterThan(0));
      expect(
          provider.error,
          contains(
              'Failed to create sound test')); // Should contain error message

      // Test error clearing
      provider.clearError();
      expect(provider.error, null);
    });

    test('fetchSoundTests should update soundTests state', () async {
      // Arrange
      final mockSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound 1',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: {'frequency': 1000, 'volume': 0.7},
        ),
        'test2': SoundTest(
          id: 'test2',
          name: 'Test Sound 2',
          dateCreated: DateTime(2023, 1, 2),
          soundTestData: {'frequency': 2000, 'volume': 0.8},
        ),
      };

      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => mockSoundTests);

      // Act
      await provider.fetchSoundTests();

      // Assert
      expect(provider.soundTests.length, 2);
      expect(provider.soundTests['test1']?.name, 'Test Sound 1');
      expect(provider.soundTests['test2']?.name, 'Test Sound 2');
      expect(provider.isLoading, isFalse);
    });

    test('createSoundTest should add a sound test and refresh the list',
        () async {
      // Arrange
      final newSoundTest = SoundTest(
        id: 'test3',
        name: 'New Sound Test',
        dateCreated: DateTime(2023, 1, 3),
        soundTestData: {'frequency': 3000, 'volume': 0.9},
      );

      when(mockRepository.addSoundTest(newSoundTest)).thenAnswer((_) async {
        return;
      });
      when(mockRepository.getAllSoundTests()).thenAnswer((_) async => {
            'test3': newSoundTest,
          });

      // Act
      await provider.createSoundTest(newSoundTest);

      // Assert
      expect(provider.soundTests.length, 1);
      expect(provider.soundTests['test3']?.name, 'New Sound Test');
      verify(mockRepository.addSoundTest(newSoundTest)).called(1);
    });

    test('updateSoundTest should update a sound test and refresh the list',
        () async {
      // Arrange
      final initialSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound 1',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: {'frequency': 1000, 'volume': 0.7},
        ),
      };

      final updatedSoundTest = SoundTest(
        id: 'test1',
        name: 'Updated Sound Test',
        dateCreated: DateTime(2023, 1, 1),
        soundTestData: {'frequency': 1000, 'volume': 0.8},
      );

      final Map<String, SoundTest> finalSoundTests = {
        'test1': updatedSoundTest
      };

      // Setup for first call to getAllSoundTests (initial tests)
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => initialSoundTests);

      // Act
      await provider.fetchSoundTests(); // Load initial data

      // Reset the mock to set up for second call
      reset(mockRepository);

      // Setup for updateSoundTest call
      when(mockRepository.updateSoundTest(updatedSoundTest))
          .thenAnswer((_) async {});

      // Setup for second call to getAllSoundTests after update
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => finalSoundTests);

      // Act - update test
      await provider.updateSoundTest(updatedSoundTest);

      // Assert
      expect(provider.soundTests.length, 1);
      expect(provider.soundTests['test1']?.name, 'Updated Sound Test');
      expect(provider.soundTests['test1']?.soundTestData['volume'], 0.8);
      verify(mockRepository.updateSoundTest(updatedSoundTest)).called(1);
    });

    test('deleteSoundTest should remove a sound test and refresh the list',
        () async {
      // Arrange
      final initialSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound 1',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: {'frequency': 1000, 'volume': 0.7},
        ),
      };

      const soundTestId = 'test1';

      // Setup for first call to getAllSoundTests (initial tests)
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => initialSoundTests);

      // Act
      await provider.fetchSoundTests(); // Load initial data

      // Reset the mock to set up for second call
      reset(mockRepository);

      // Setup for deleteSoundTest call
      when(mockRepository.deleteSoundTest(soundTestId))
          .thenAnswer((_) async {});

      // Setup for second call to getAllSoundTests after deletion
      when(mockRepository.getAllSoundTests()).thenAnswer((_) async => {});

      // Act - delete test
      await provider.deleteSoundTest(soundTestId);

      // Assert
      expect(provider.soundTests, isEmpty);
      verify(mockRepository.deleteSoundTest(soundTestId)).called(1);
    });

    test('setActiveSoundTest should update the active sound test', () async {
      // Arrange
      final mockSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound 1',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: {'frequency': 1000, 'volume': 0.7},
        ),
      };

      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => mockSoundTests);
      await provider.fetchSoundTests(); // Load test data

      // Act
      provider.setActiveSoundTest('test1');

      // Assert
      expect(provider.activeSoundTestId, 'test1');
      expect(provider.activeSoundTest?.name, 'Test Sound 1');
    });

    test('clearActiveSoundTest should clear the active sound test', () async {
      // Arrange
      final mockSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound 1',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: {'frequency': 1000, 'volume': 0.7},
        ),
      };

      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => mockSoundTests);
      await provider.fetchSoundTests(); // Load test data
      provider.setActiveSoundTest('test1');

      // Act
      provider.clearActiveSoundTest();

      // Assert
      expect(provider.activeSoundTestId, isNull);
      expect(provider.activeSoundTest, isNull);
    });

    test('getSoundTestById should return the correct sound test', () async {
      // Arrange
      final mockSoundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound 1',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: {'frequency': 1000, 'volume': 0.7},
        ),
        'test2': SoundTest(
          id: 'test2',
          name: 'Test Sound 2',
          dateCreated: DateTime(2023, 1, 2),
          soundTestData: {'frequency': 2000, 'volume': 0.8},
        ),
      };

      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => mockSoundTests);
      await provider.fetchSoundTests(); // Load test data

      // Act & Assert
      expect(provider.getSoundTestById('test1')?.name, 'Test Sound 1');
      expect(provider.getSoundTestById('test2')?.name, 'Test Sound 2');
      expect(provider.getSoundTestById('nonexistent'), isNull);
    });

    test('error handling during fetchSoundTests', () async {
      // Arrange
      when(mockRepository.getAllSoundTests())
          .thenThrow(Exception('Network error'));

      // Act
      await provider.fetchSoundTests();

      // Assert
      expect(provider.error, contains('Failed to load sound tests'));
      expect(provider.isLoading, isFalse);
    });
  });
}
