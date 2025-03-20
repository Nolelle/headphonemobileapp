import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';

void main() {
  group('PresetRepository Tests', () {
    late PresetRepository repository;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      repository = PresetRepository();
    });

    test(
        'testAddPreset - should save new preset to SharedPreferences with correct format',
        () async {
      // Arrange
      // Set up SharedPreferences mock with empty initial values
      SharedPreferences.setMockInitialValues({});

      // Create a test preset
      final currentTime = DateTime(
          2024, 3, 15, 10, 0, 0); // Fixed timestamp for consistent testing
      final preset = Preset(
        id: 'new_preset',
        name: 'New Preset',
        dateCreated: currentTime,
        presetData: {'db_valueOV': 5.0},
      );

      // Act - Call the method under test
      await repository.addPreset(preset);

      // Get the SharedPreferences instance to verify saved data
      final prefs = await SharedPreferences.getInstance();
      final storedJsonString = prefs.getString('presetsMap');

      // Assert
      expect(storedJsonString, isNotNull);

      // Verify the stored JSON structure
      final Map<String, dynamic> storedData = jsonDecode(storedJsonString!);

      // Check if our preset ID exists in the stored data
      expect(storedData.containsKey('new_preset'), true,
          reason: 'Stored data should contain the preset ID');

      // Check if stored preset data matches what we expect
      final storedPreset = storedData['new_preset'];
      expect(storedPreset['name'], 'New Preset');
      expect(storedPreset['presetData']['db_valueOV'], 5.0);
      expect(storedPreset['dateCreated'], '2024-03-15T10:00:00.000');
    });

    test('testAddPreset - should add new preset to existing presets', () async {
      // Arrange - Set up SharedPreferences with an existing preset
      const existingJson =
          '{"preset1": {"name": "Existing Preset", "presetData": {"db_valueOV": 0.0}, "dateCreated": "2024-03-10T10:00:00.000"}}';
      SharedPreferences.setMockInitialValues({'presetsMap': existingJson});

      // Create a new preset to add
      final currentTime = DateTime(2024, 3, 15, 10, 0, 0);
      final newPreset = Preset(
        id: 'new_preset',
        name: 'New Preset',
        dateCreated: currentTime,
        presetData: {'db_valueOV': 5.0},
      );

      // Act - Add the new preset
      await repository.addPreset(newPreset);

      // Get the updated presets
      final updatedPresets = await repository.getAllPresets();

      // Assert
      expect(updatedPresets.length, 2,
          reason: 'Should have both the existing and new preset');

      // Check existing preset is still there
      expect(updatedPresets['preset1'], isNotNull);
      expect(updatedPresets['preset1']?.name, 'Existing Preset');

      // Check new preset was added correctly
      expect(updatedPresets['new_preset'], isNotNull);
      expect(updatedPresets['new_preset']?.name, 'New Preset');
      expect(updatedPresets['new_preset']?.presetData['db_valueOV'], 5.0);
    });
  });
}
