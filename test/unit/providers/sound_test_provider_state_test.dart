import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/repositories/sound_test_repository.dart';

@GenerateMocks([SoundTestRepository])
import 'sound_test_provider_state_test.mocks.dart';

void main() {
  group('SoundTestProvider State Management Tests', () {
    late MockSoundTestRepository mockRepository;
    late SoundTestProvider provider;

    setUp(() {
      mockRepository = MockSoundTestRepository();

      // Mock default behavior to avoid "missing stub" errors
      when(mockRepository.getAllSoundTests()).thenAnswer((_) async => {});

      provider = SoundTestProvider(mockRepository);
    });

    test(
        'testSoundTestProviderState - should update loading and error states correctly',
        () async {
      // Arrange
      final validSoundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: DateTime.now(),
        soundTestData: {
          'L_user_250Hz_dB': 50.0,
          'R_user_500Hz_dB': 45.0,
        },
        icon: Icons.hearing,
      );

      // Success case
      when(mockRepository.addSoundTest(any)).thenAnswer((_) async {});

      // Act - Create sound test successfully
      expect(provider.isLoading, false); // Initial state
      expect(provider.error, null); // Initial state

      final createFuture = provider.createSoundTest(validSoundTest);

      // Assert - Loading state should be true during operation
      expect(provider.isLoading, true);

      // Wait for operation to complete
      await createFuture;

      // Assert - Final state after successful operation
      expect(provider.isLoading, false);
      expect(provider.error, null);
      verify(mockRepository.addSoundTest(validSoundTest)).called(1);

      // Arrange - Error case
      final error = Exception('Test error');
      when(mockRepository.addSoundTest(any)).thenThrow(error);

      // Act - Attempt to create sound test with error
      final errorFuture = provider.createSoundTest(validSoundTest);

      // Assert - Loading state during operation
      expect(provider.isLoading, true);

      // Wait for operation to complete with error
      await errorFuture;

      // Assert - Final state after operation with error
      expect(provider.isLoading, false);
      expect(provider.error, isNotNull);

      // Act - Clear error
      provider.clearError();

      // Assert - Error should be cleared
      expect(provider.error, null);
    });

    test(
        'testSoundTestProviderState - should handle repository errors gracefully',
        () async {
      // Arrange
      final validSoundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: DateTime.now(),
        soundTestData: {
          'L_user_250Hz_dB': 50.0,
        },
        icon: Icons.hearing,
      );

      // Error cases
      when(mockRepository.addSoundTest(any))
          .thenThrow(Exception('Database error'));
      when(mockRepository.getAllSoundTests())
          .thenThrow(Exception('Network error'));

      // Act & Assert - Create sound test with error
      await provider.createSoundTest(validSoundTest);
      expect(provider.error, contains('Failed to create sound test'));

      // Act & Assert - Fetch sound tests with error
      provider.clearError(); // Clear previous error
      await provider.fetchSoundTests();
      expect(provider.error, contains('Failed to load sound tests'));

      // Ensure provider is usable even after errors
      expect(provider.isLoading, false);
    });
  });
}
