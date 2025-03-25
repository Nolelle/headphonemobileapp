import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';

void main() {
  group('PresetRepository Update Tests', () {
    late PresetRepository repository;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      repository = PresetRepository();
    });

    test('testUpdatePreset - should update existing preset correctly',
        () async {
      // Arrange - Set up SharedPreferences with an existing preset
      const existingJson =
          '{"preset1": {"name": "Original Name", "presetData": {"db_valueOV": 0.0}, "dateCreated": "2024-03-10T10:00:00.000"}}';
      SharedPreferences.setMockInitialValues({'presetsMap': existingJson});

      // Create an updated version of the preset
      final updatedPreset = Preset(
        id: 'preset1',
        name: 'Updated Name',
        dateCreated: DateTime(2024, 3, 10, 10, 0, 0), // Keep original date
        presetData: {'db_valueOV': 8.5}, // Updated value
      );

      // Act - Update the preset
      await repository.updatePreset(updatedPreset);

      // Get the SharedPreferences to verify saved data
      final prefs = await SharedPreferences.getInstance();
      final storedJsonString = prefs.getString('presetsMap');

      // Assert
      expect(storedJsonString, isNotNull);

      // Verify the stored JSON structure
      final Map<String, dynamic> storedData = jsonDecode(storedJsonString!);

      // Check if the preset was updated
      expect(storedData.containsKey('preset1'), true);
      final storedPreset = storedData['preset1'];
      expect(storedPreset['name'], 'Updated Name');
      expect(storedPreset['presetData']['db_valueOV'], 8.5);

      // Additional check using the repository's own method
      final updatedPresets = await repository.getAllPresets();
      expect(updatedPresets['preset1']?.name, 'Updated Name');
      expect(updatedPresets['preset1']?.presetData['db_valueOV'], 8.5);
    });

    test('testUpdatePreset - should add preset if it does not exist', () async {
      // Arrange - Set up empty SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Create a new preset
      final newPreset = Preset(
        id: 'new_preset',
        name: 'New Preset',
        dateCreated: DateTime(2024, 3, 15, 10, 0, 0),
        presetData: {'db_valueOV': 5.0},
      );

      // Act - Update a non-existent preset (should add it)
      await repository.updatePreset(newPreset);

      // Get the updated presets
      final updatedPresets = await repository.getAllPresets();

      // Assert
      expect(updatedPresets.length, 1);
      expect(updatedPresets['new_preset'], isNotNull);
      expect(updatedPresets['new_preset']?.name, 'New Preset');
      expect(updatedPresets['new_preset']?.presetData['db_valueOV'], 5.0);
    });
  });
}
