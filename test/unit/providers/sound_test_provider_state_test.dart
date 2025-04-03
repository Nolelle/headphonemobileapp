import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';

@GenerateMocks([SoundTestRepository])
import 'sound_test_provider_state_test.mocks.dart';

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

void main() {
  group('SoundTestProvider State Management Tests', () {
    late MockSoundTestRepository mockRepository;
    late SoundTestProvider provider;

    setUp(() {
      mockRepository = MockSoundTestRepository();
      provider = SoundTestProvider(mockRepository);
    });

    test('state management - loading state should be set correctly', () async {
      // Arrange
      final soundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound Test 1',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: createStandardTestData(40.0),
        ),
      };

      // Mock repository behavior
      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => soundTests);

      // Use a listener to track state changes
      final stateChanges = <bool>[];
      provider.addListener(() {
        stateChanges.add(provider.isLoading);
      });

      // Act
      await provider.fetchSoundTests();

      // Assert
      // Check that loading state changes from true to false
      // First notification: isLoading = true
      // Second notification: isLoading = false after successful fetch
      expect(stateChanges, [true, false, false]);
      expect(provider.isLoading, isFalse);
    });

    test('state management - error state should be set correctly', () async {
      // Arrange
      final testException = Exception('Test error');
      when(mockRepository.getAllSoundTests()).thenThrow(testException);

      // Use a listener to track state changes
      final errors = <String?>[];
      provider.addListener(() {
        errors.add(provider.error);
      });

      // Act
      await provider.fetchSoundTests();

      // Assert
      // The error notifications sequence should be:
      // 1. null - when isLoading is set to true
      // 2. error message - when error occurs
      expect(errors[1], contains('Failed to load sound tests'));
      expect(provider.error, contains('Failed to load sound tests'));
    });

    test('state management - clearError should clear error state', () async {
      // Arrange - create an error condition
      final testException = Exception('Test error');
      when(mockRepository.getAllSoundTests()).thenThrow(testException);
      await provider.fetchSoundTests();
      expect(provider.error, isNotNull);

      // Use a listener to track state changes
      var errorCleared = false;
      provider.addListener(() {
        if (provider.error == null) {
          errorCleared = true;
        }
      });

      // Act
      provider.clearError();

      // Assert
      expect(errorCleared, isTrue);
      expect(provider.error, isNull);
    });

    test('state management - active sound test handling', () async {
      // Arrange
      final soundTests = {
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Sound Test 1',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: createStandardTestData(40.0),
        ),
        'test2': SoundTest(
          id: 'test2',
          name: 'Test Sound Test 2',
          dateCreated: DateTime(2023, 1, 2),
          soundTestData: createStandardTestData(50.0),
        ),
      };

      when(mockRepository.getAllSoundTests())
          .thenAnswer((_) async => soundTests);
      when(mockRepository.deleteSoundTest(any)).thenAnswer((_) async {});

      // Act
      await provider.fetchSoundTests();

      // Assert
      // Provider should have kept only the most recent sound test (test2)
      expect(provider.soundTests.length, 1);
      expect(provider.soundTests.containsKey('test2'), isTrue);
      expect(provider.activeSoundTestId, 'test2');
    });
  });
}
