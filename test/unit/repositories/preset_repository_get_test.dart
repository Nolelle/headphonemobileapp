import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';

void main() {
  group('PresetRepository Tests', () {
    late PresetRepository repository;

    setUp(() {
      repository = PresetRepository();
    });

    test(
        'testGetAllPresets - should retrieve presets from SharedPreferences correctly',
        () async {
      // Arrange - Set up mock SharedPreferences with test data
      const jsonString =
          '{"preset1": {"name": "Test Preset", "presetData": {"db_valueOV": 0.0}, "dateCreated": "2024-03-10T10:00:00.000"}}';
      SharedPreferences.setMockInitialValues({'presetsMap': jsonString});

      // Act - Call the method under test
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets.length, 1, reason: 'Should have one preset');
      expect(presets['preset1']?.name, 'Test Preset',
          reason: 'Preset name should match');
      expect(presets['preset1']?.presetData['db_valueOV'], 0.0,
          reason: 'Preset data should match');
      expect(presets['preset1']?.dateCreated, DateTime(2024, 3, 10, 10, 0, 0),
          reason: 'Date should be parsed correctly');
    });

    test(
        'testGetAllPresets - should return empty map when no presets are stored',
        () async {
      // Arrange - Set up mock SharedPreferences with no data
      SharedPreferences.setMockInitialValues({});

      // Act - Call the method under test
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets, isEmpty,
          reason: 'Should return an empty map when no presets are stored');
    });
  });
}
