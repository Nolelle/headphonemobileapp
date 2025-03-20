import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';

void main() {
  group('PresetRepository Corrupted Data Tests', () {
    late PresetRepository repository;

    setUp(() {
      repository = PresetRepository();
    });

    test('testCorruptedData - should handle invalid JSON gracefully', () async {
      // Arrange - Set up mock SharedPreferences with invalid JSON
      SharedPreferences.setMockInitialValues(
          {'presetsMap': '{invalid json data}'});

      // Act - Call the method under test
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets, isEmpty,
          reason: 'Should return empty map when data is corrupted');
    });

    test('testCorruptedData - should handle malformed but valid JSON',
        () async {
      // Arrange - Set up mock SharedPreferences with valid JSON but wrong structure
      SharedPreferences.setMockInitialValues({
        'presetsMap':
            '{"key1": "value1", "key2": 123}' // Not a proper preset structure
      });

      // Act - Call the method under test
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets, isEmpty,
          reason: 'Should return empty map when JSON format is incorrect');
    });

    test('testCorruptedData - should handle partial corruption', () async {
      // Arrange - Set up mock SharedPreferences with partially valid data (one valid, one invalid)
      const partiallyValidJson =
          '{"valid_preset": {"name": "Valid Preset", "presetData": {"db_valueOV": 0.0}, "dateCreated": "2024-03-10T10:00:00.000"}, '
          '"invalid_preset": {"name": 123, "bad_structure": true}}';

      SharedPreferences.setMockInitialValues(
          {'presetsMap': partiallyValidJson});

      // Act - Call the method under test
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets, isEmpty,
          reason: 'Should return empty map when any part of data is corrupted');
    });

    test('testCorruptedData - should handle missing required fields', () async {
      // Arrange - Set up mock SharedPreferences with missing required fields
      const missingFieldsJson =
          '{"missing_fields": {"name": "Missing Fields Preset", "presetData": {"db_valueOV": 0.0}}}'; // Missing dateCreated

      SharedPreferences.setMockInitialValues({'presetsMap': missingFieldsJson});

      // Act - Call the method under test
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets, isEmpty,
          reason: 'Should return empty map when required fields are missing');
    });

    test('testCorruptedData - should handle nonexistent key', () async {
      // Arrange - Set up mock SharedPreferences with no presets key
      SharedPreferences.setMockInitialValues({'some_other_key': 'some_value'});

      // Act - Call the method under test
      final presets = await repository.getAllPresets();

      // Assert
      expect(presets, isEmpty,
          reason: 'Should return empty map when key does not exist');
    });
  });
}
