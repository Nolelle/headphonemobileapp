import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import '../mocks/mock_preset_provider.mocks.dart';

void main() {
  group('PresetProvider Tests', () {
    late MockPresetRepository mockRepository;
    late PresetProvider provider;

    setUp(() {
      mockRepository = MockPresetRepository();
      provider = PresetProvider(mockRepository);
    });

    test('initial state should be empty', () {
      expect(provider.presets, isEmpty);
      expect(provider.activePresetId, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('fetchPresets should update presets state', () async {
      // Arrange
      final mockPresets = {
        'preset1': Preset(
          id: 'preset1',
          name: 'Test Preset 1',
          dateCreated: DateTime(2023, 1, 1),
          presetData: {'db_valueOV': 0.0},
        ),
        'preset2': Preset(
          id: 'preset2',
          name: 'Test Preset 2',
          dateCreated: DateTime(2023, 1, 2),
          presetData: {'db_valueOV': 1.0},
        ),
      };

      when(mockRepository.getAllPresets()).thenAnswer((_) async => mockPresets);

      // Act
      await provider.fetchPresets();

      // Assert
      expect(provider.presets.length, 2);
      expect(provider.presets['preset1']?.name, 'Test Preset 1');
      expect(provider.presets['preset2']?.name, 'Test Preset 2');
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('createPreset should add a preset and refresh the list', () async {
      // Arrange
      final newPreset = Preset(
        id: 'new_preset',
        name: 'New Preset',
        dateCreated: DateTime(2023, 1, 1),
        presetData: {'db_valueOV': 0.0},
      );

      final mockPresets = {
        'new_preset': newPreset,
      };

      when(mockRepository.addPreset(newPreset)).thenAnswer((_) async {});
      when(mockRepository.getAllPresets()).thenAnswer((_) async => mockPresets);

      // Act
      await provider.createPreset(newPreset);

      // Assert
      verify(mockRepository.addPreset(newPreset)).called(1);
      verify(mockRepository.getAllPresets()).called(1);
      expect(provider.presets.length, 1);
      expect(provider.presets['new_preset']?.name, 'New Preset');
    });

    test('updatePreset should update a preset and refresh the list', () async {
      // Arrange
      final updatedPreset = Preset(
        id: 'preset1',
        name: 'Updated Preset',
        dateCreated: DateTime(2023, 1, 1),
        presetData: {'db_valueOV': 5.0},
      );

      final mockPresets = {
        'preset1': updatedPreset,
      };

      when(mockRepository.updatePreset(updatedPreset)).thenAnswer((_) async {});
      when(mockRepository.getAllPresets()).thenAnswer((_) async => mockPresets);

      // Act
      await provider.updatePreset(updatedPreset);

      // Assert
      verify(mockRepository.updatePreset(updatedPreset)).called(1);
      verify(mockRepository.getAllPresets()).called(1);
      expect(provider.presets.length, 1);
      expect(provider.presets['preset1']?.name, 'Updated Preset');
      expect(provider.presets['preset1']?.presetData['db_valueOV'], 5.0);
    });

    test('deletePreset should remove a preset and refresh the list', () async {
      // Arrange
      const presetId = 'preset1';

      when(mockRepository.deletePreset(presetId)).thenAnswer((_) async {});
      when(mockRepository.getAllPresets()).thenAnswer((_) async => {});

      // Set active preset to be deleted
      provider.setActivePreset(presetId);

      // Act
      await provider.deletePreset(presetId);

      // Assert
      verify(mockRepository.deletePreset(presetId)).called(1);
      verify(mockRepository.getAllPresets()).called(1);
      expect(provider.presets, isEmpty);
      expect(provider.activePresetId, isNull);
    });

    test('setActivePreset should update activePresetId', () async {
      // Arrange
      final mockPresets = {
        'preset1': Preset(
          id: 'preset1',
          name: 'Test Preset 1',
          dateCreated: DateTime(2023, 1, 1),
          presetData: {'db_valueOV': 0.0},
        ),
      };

      when(mockRepository.getAllPresets()).thenAnswer((_) async => mockPresets);
      await provider.fetchPresets();

      // Act
      provider.setActivePreset('preset1');

      // Assert
      expect(provider.activePresetId, 'preset1');
      expect(provider.activePreset?.name, 'Test Preset 1');
    });

    test('clearActivePreset should set activePresetId to null', () async {
      // Arrange
      final mockPresets = {
        'preset1': Preset(
          id: 'preset1',
          name: 'Test Preset 1',
          dateCreated: DateTime(2023, 1, 1),
          presetData: {'db_valueOV': 0.0},
        ),
      };

      when(mockRepository.getAllPresets()).thenAnswer((_) async => mockPresets);
      await provider.fetchPresets();
      provider.setActivePreset('preset1');

      // Act
      provider.clearActivePreset();

      // Assert
      expect(provider.activePresetId, isNull);
      expect(provider.activePreset, isNull);
    });

    test('toggleDropdown should toggle dropdown state for a preset', () async {
      // Arrange
      final mockPresets = {
        'preset1': Preset(
          id: 'preset1',
          name: 'Test Preset 1',
          dateCreated: DateTime(2023, 1, 1),
          presetData: {'db_valueOV': 0.0},
        ),
      };

      when(mockRepository.getAllPresets()).thenAnswer((_) async => mockPresets);
      await provider.fetchPresets();

      // Act - toggle to true
      provider.toggleDropdown('preset1');

      // Assert
      expect(provider.dropdownStates['preset1'], isTrue);

      // Act - toggle to false
      provider.toggleDropdown('preset1');

      // Assert
      expect(provider.dropdownStates['preset1'], isFalse);

      // Act - set explicitly to true
      provider.toggleDropdown('preset1', true);

      // Assert
      expect(provider.dropdownStates['preset1'], isTrue);
    });

    test('getPresetById should return the correct preset', () async {
      // Arrange
      final mockPresets = {
        'preset1': Preset(
          id: 'preset1',
          name: 'Test Preset 1',
          dateCreated: DateTime(2023, 1, 1),
          presetData: {'db_valueOV': 0.0},
        ),
      };

      when(mockRepository.getAllPresets()).thenAnswer((_) async => mockPresets);
      await provider.fetchPresets();

      // Act
      final preset = provider.getPresetById('preset1');

      // Assert
      expect(preset?.id, 'preset1');
      expect(preset?.name, 'Test Preset 1');
    });

    test('clearError should set error to null', () {
      // Arrange - simulate an error state
      provider = PresetProvider(mockRepository);
      final errorField = provider.error;

      // Act
      provider.clearError();

      // Assert
      expect(provider.error, isNull);
    });
  });
}
