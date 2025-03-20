import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';

void main() {
  group('PresetRepository Delete Tests', () {
    late PresetRepository repository;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      repository = PresetRepository();
    });

    test('testDeletePreset - should remove preset correctly', () async {
      // Arrange - Set up SharedPreferences with two existing presets
      const existingJson =
          '{"preset1": {"name": "Preset 1", "presetData": {"db_valueOV": 0.0}, "dateCreated": "2024-03-10T10:00:00.000"}, '
          '"preset2": {"name": "Preset 2", "presetData": {"db_valueOV": 5.0}, "dateCreated": "2024-03-15T10:00:00.000"}}';
      SharedPreferences.setMockInitialValues({'presetsMap': existingJson});

      // Verify both presets exist initially
      final initialPresets = await repository.getAllPresets();
      expect(initialPresets.length, 2);
      expect(initialPresets.containsKey('preset1'), true);
      expect(initialPresets.containsKey('preset2'), true);

      // Act - Delete the first preset
      await repository.deletePreset('preset1');

      // Assert - Check that preset1 was removed but preset2 remains
      final updatedPresets = await repository.getAllPresets();
      expect(updatedPresets.length, 1);
      expect(updatedPresets.containsKey('preset1'), false);
      expect(updatedPresets.containsKey('preset2'), true);

      // Verify the data in SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      final storedJsonString = prefs.getString('presetsMap');
      final Map<String, dynamic> storedData = jsonDecode(storedJsonString!);

      expect(storedData.containsKey('preset1'), false);
      expect(storedData.containsKey('preset2'), true);
    });

    test(
        'testDeletePreset - should handle deleting non-existent preset gracefully',
        () async {
      // Arrange - Set up SharedPreferences with one existing preset
      const existingJson =
          '{"preset1": {"name": "Preset 1", "presetData": {"db_valueOV": 0.0}, "dateCreated": "2024-03-10T10:00:00.000"}}';
      SharedPreferences.setMockInitialValues({'presetsMap': existingJson});

      // Act - Delete a non-existent preset
      await repository.deletePreset('non_existent_preset');

      // Assert - The existing preset should still be there
      final updatedPresets = await repository.getAllPresets();
      expect(updatedPresets.length, 1);
      expect(updatedPresets.containsKey('preset1'), true);
    });

    test('testDeletePreset - should handle empty SharedPreferences gracefully',
        () async {
      // Arrange - Empty SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Act - Delete a preset from empty storage
      await repository.deletePreset('any_preset');

      // Assert - Nothing should have changed
      final updatedPresets = await repository.getAllPresets();
      expect(updatedPresets.isEmpty, true);
    });
  });
}
