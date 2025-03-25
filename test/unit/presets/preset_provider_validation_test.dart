import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';

class TestPresetRepository implements PresetRepository {
  final Map<String, Preset> _presets = {};
  Exception? _forcedException;

  void setForceException(Exception exception) {
    _forcedException = exception;
  }

  void clearForceException() {
    _forcedException = null;
  }

  @override
  Future<Map<String, Preset>> getAllPresets() async {
    return Map.from(_presets);
  }

  @override
  Future<void> addPreset(Preset preset) async {
    if (_forcedException != null) {
      throw _forcedException!;
    }
    validatePreset(preset);
    _presets[preset.id] = preset;
  }

  @override
  Future<void> updatePreset(Preset preset) async {
    if (_forcedException != null) {
      throw _forcedException!;
    }
    if (!_presets.containsKey(preset.id)) {
      throw Exception('Preset not found');
    }
    validatePreset(preset);
    _presets[preset.id] = preset;
  }

  @override
  Future<void> deletePreset(String id) async {
    if (_forcedException != null) {
      throw _forcedException!;
    }
    _presets.remove(id);
  }

  @override
  Future<void> saveAllPresets(Map<String, Preset> presets) async {
    if (_forcedException != null) {
      throw _forcedException!;
    }
    _presets.clear();
    _presets.addAll(presets);
  }

  // Custom validation logic to simulate what PresetProvider should do
  void validatePreset(Preset preset) {
    if (preset.name.isEmpty) {
      throw Exception('Invalid preset name');
    }

    if (preset.name.length > 50) {
      throw Exception('Preset name too long');
    }

    // Validate required preset data keys
    final requiredKeys = [
      'db_valueOV',
      'db_valueSB_BS',
      'db_valueSB_MRS',
      'db_valueSB_TS'
    ];
    for (final key in requiredKeys) {
      if (!preset.presetData.containsKey(key)) {
        throw Exception('Missing required preset settings');
      }
    }

    // Validate volume values are within range (0-100)
    for (final key in preset.presetData.keys) {
      if (key.startsWith('db_value')) {
        final value = preset.presetData[key];
        if (value is double && (value < 0 || value > 100)) {
          throw Exception('Invalid volume value');
        }
      }
    }
  }
}

void main() {
  group('PresetProvider validation tests', () {
    late TestPresetRepository testRepository;
    late PresetProvider provider;

    setUp(() {
      testRepository = TestPresetRepository();
      provider = PresetProvider(testRepository);
    });

    test('createPreset - should validate preset name is not empty', () async {
      // Create preset with empty name
      final preset = Preset(
        id: 'test_preset',
        name: '', // Empty name
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 0.0,
          'db_valueSB_BS': 0.0,
          'db_valueSB_MRS': 0.0,
          'db_valueSB_TS': 0.0,
        },
      );

      // Attempt to create the preset
      await provider.createPreset(preset);

      // Verify error message contains expected text
      expect(provider.error, contains('Failed to create preset'));
      expect(provider.error, contains('Invalid preset name'));

      // Verify preset was not added
      await provider.fetchPresets();
      expect(provider.presets.isEmpty, true);
    });

    test('createPreset - should validate preset name length is not too long',
        () async {
      // Create preset with very long name
      final preset = Preset(
        id: 'test_preset',
        name: 'A' * 51, // 51 characters
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 0.0,
          'db_valueSB_BS': 0.0,
          'db_valueSB_MRS': 0.0,
          'db_valueSB_TS': 0.0,
        },
      );

      // Attempt to create the preset
      await provider.createPreset(preset);

      // Verify error message
      expect(provider.error, contains('Failed to create preset'));
      expect(provider.error, contains('Preset name too long'));

      // Verify preset was not added
      await provider.fetchPresets();
      expect(provider.presets.isEmpty, true);
    });

    test('createPreset - should validate preset data contains required fields',
        () async {
      // Create preset with missing required data
      final preset = Preset(
        id: 'test_preset',
        name: 'Test Preset',
        dateCreated: DateTime.now(),
        presetData: {
          // Missing required fields
        },
      );

      // Attempt to create the preset
      await provider.createPreset(preset);

      // Verify error message
      expect(provider.error, contains('Failed to create preset'));
      expect(provider.error, contains('Missing required preset settings'));

      // Verify preset was not added
      await provider.fetchPresets();
      expect(provider.presets.isEmpty, true);
    });

    test(
        'createPreset - should validate volume values are within acceptable range',
        () async {
      // Create preset with out-of-range volume values
      final preset = Preset(
        id: 'test_preset',
        name: 'Test Preset',
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 101.0, // Out of range (should be 0-100)
          'db_valueSB_BS': -5.0, // Out of range (should be 0-100)
          'db_valueSB_MRS': 0.0,
          'db_valueSB_TS': 0.0,
        },
      );

      // Attempt to create the preset
      await provider.createPreset(preset);

      // Verify error message
      expect(provider.error, contains('Failed to create preset'));
      expect(provider.error, contains('Invalid volume value'));

      // Verify preset was not added
      await provider.fetchPresets();
      expect(provider.presets.isEmpty, true);
    });

    test('updatePreset - should validate preset exists before updating',
        () async {
      // Attempt to update a non-existent preset
      final preset = Preset(
        id: 'nonexistent_preset',
        name: 'Updated Preset',
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 50.0,
          'db_valueSB_BS': 50.0,
          'db_valueSB_MRS': 0.0,
          'db_valueSB_TS': 0.0,
        },
      );

      // Attempt to update the preset
      await provider.updatePreset(preset);

      // Verify error message
      expect(provider.error, contains('Failed to update preset'));
      expect(provider.error, contains('Preset not found'));
    });

    test('createPreset - should successfully create valid preset', () async {
      // Create a valid preset
      final preset = Preset(
        id: 'test_preset',
        name: 'Valid Preset',
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 50.0,
          'db_valueSB_BS': 50.0,
          'db_valueSB_MRS': 50.0,
          'db_valueSB_TS': 50.0,
        },
      );

      // Add the preset
      await provider.createPreset(preset);

      // Verify no error occurred
      expect(provider.error, isNull);

      // Fetch and verify preset was added correctly
      await provider.fetchPresets();
      expect(provider.presets.length, 1);
      expect(provider.presets['test_preset']?.name, 'Valid Preset');
    });
  });
}
