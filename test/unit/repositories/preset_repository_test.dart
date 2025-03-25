import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';
import 'package:projects/features/presets/models/preset.dart';

void main() {
  group('PresetRepository Tests', () {
    late PresetRepository repository;

    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      repository = PresetRepository();
    });

    test('should return empty map when no presets are saved', () async {
      // Act
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets, isEmpty);
    });

    test('should save and retrieve a preset', () async {
      // Arrange
      final preset = Preset(
        id: 'test_preset_1',
        name: 'Test Preset',
        dateCreated: DateTime(2023, 1, 1),
        presetData: {
          'db_valueOV': 0.0,
          'db_valueSB_BS': 1.0,
          'db_valueSB_MRS': 2.0,
          'db_valueSB_TS': 3.0,
          'reduce_background_noise': true,
          'reduce_wind_noise': false,
          'soften_sudden_noise': true,
        },
      );

      // Act
      await repository.addPreset(preset);
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets.length, 1);
      expect(presets['test_preset_1']?.name, 'Test Preset');
      expect(presets['test_preset_1']?.presetData['db_valueOV'], 0.0);
      expect(presets['test_preset_1']?.presetData['reduce_background_noise'],
          true);
    });

    test('should update an existing preset', () async {
      // Arrange
      final preset = Preset(
        id: 'test_preset_1',
        name: 'Test Preset',
        dateCreated: DateTime(2023, 1, 1),
        presetData: {'db_valueOV': 0.0},
      );
      await repository.addPreset(preset);

      final updatedPreset = Preset(
        id: 'test_preset_1',
        name: 'Updated Preset',
        dateCreated: DateTime(2023, 1, 2),
        presetData: {'db_valueOV': 5.0},
      );

      // Act
      await repository.updatePreset(updatedPreset);
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets.length, 1);
      expect(presets['test_preset_1']?.name, 'Updated Preset');
      expect(presets['test_preset_1']?.presetData['db_valueOV'], 5.0);
    });

    test('should delete a preset', () async {
      // Arrange
      final preset = Preset(
        id: 'test_preset_1',
        name: 'Test Preset',
        dateCreated: DateTime(2023, 1, 1),
        presetData: {'db_valueOV': 0.0},
      );
      await repository.addPreset(preset);

      // Act
      await repository.deletePreset('test_preset_1');
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets, isEmpty);
    });

    test('should handle multiple presets', () async {
      // Arrange
      final preset1 = Preset(
        id: 'test_preset_1',
        name: 'Test Preset 1',
        dateCreated: DateTime(2023, 1, 1),
        presetData: {'db_valueOV': 0.0},
      );

      final preset2 = Preset(
        id: 'test_preset_2',
        name: 'Test Preset 2',
        dateCreated: DateTime(2023, 1, 2),
        presetData: {'db_valueOV': 1.0},
      );

      // Act
      await repository.addPreset(preset1);
      await repository.addPreset(preset2);
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets.length, 2);
      expect(presets['test_preset_1']?.name, 'Test Preset 1');
      expect(presets['test_preset_2']?.name, 'Test Preset 2');
    });
  });
}
