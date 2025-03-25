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
      // Mock default behavior
      when(mockRepository.getAllSoundTests()).thenAnswer((_) async => {});
      provider = SoundTestProvider(mockRepository);
    });

    test(
        'testCreateSoundTest - provider should call repository method and update state',
        () async {
      // Arrange
      final currentTime = DateTime.now();
      final soundTest = SoundTest(
        id: 'test_id',
        name: 'Test Profile',
        dateCreated: currentTime,
        soundTestData: {'L_user_250Hz_dB': 0.5},
        icon: Icons.hearing,
      );

      // Mock repository behavior for successful operation
      when(mockRepository.addSoundTest(any)).thenAnswer((_) async {});

      // Track state changes
      var stateChanged = false;
      provider.addListener(() {
        stateChanged = true;
      });

      // Act
      await provider.createSoundTest(soundTest);

      // Assert
      // Verify repository method called with correct parameters
      verify(mockRepository.addSoundTest(soundTest)).called(1);

      // Verify provider state updated correctly
      // Note: Due to bug documented in sound_test_provider_state_test.dart,
      // we don't check for isLoading = false after error conditions
      expect(provider.isLoading, false,
          reason: 'isLoading should be false after successful operation');
      expect(provider.error, null,
          reason: 'error should be null after successful operation');
      expect(stateChanged, true, reason: 'Provider should notify listeners');
    });
  });
}
