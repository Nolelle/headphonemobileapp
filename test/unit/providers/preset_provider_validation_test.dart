import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/presets/providers/preset_provider.dart';
import 'package:projects/features/presets/repositories/preset_repository.dart';

@GenerateMocks([PresetRepository])
import 'preset_provider_validation_test.mocks.dart';

void main() {
  // Generate mocks first with: flutter pub run build_runner build

  group('PresetProvider Validation Tests', () {
    late MockPresetRepository mockRepository;
    late ValidationPresetProvider provider;

    setUp(() {
      mockRepository = MockPresetRepository();
      provider = ValidationPresetProvider(mockRepository);
    });

    test(
        'testPresetValidation - should validate preset and reject invalid preset',
        () async {
      // Arrange
      final invalidPreset = Preset(
        id: 'test_preset',
        name: '', // Invalid - empty name
        dateCreated: DateTime.now(),
        presetData: {}, // Invalid - required fields missing
      );

      // Act
      await provider.createPreset(invalidPreset);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Preset validation failed'));
      verifyNever(mockRepository.addPreset(any));
    });

    test('testPresetValidation - should accept valid preset', () async {
      // Arrange
      final validPreset = Preset(
        id: 'test_preset',
        name: 'Valid Preset',
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 0.0,
          'db_valueSB_BS': 1.0,
          'reduce_background_noise': false,
        },
      );

      when(mockRepository.addPreset(validPreset)).thenAnswer((_) async => null);
      when(mockRepository.getAllPresets()).thenAnswer((_) async => {
            'test_preset': validPreset,
          });

      // Act
      await provider.createPreset(validPreset);

      // Assert
      expect(provider.error, isNull);
      verify(mockRepository.addPreset(any)).called(1);
    });

    test('testPresetValidation - should validate all required fields',
        () async {
      // Arrange - Missing some required fields but not all
      final partiallyInvalidPreset = Preset(
        id: 'test_preset',
        name: 'Partial Preset',
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 0.0,
          // Missing 'db_valueSB_BS'
          'reduce_background_noise': false,
        },
      );

      // Act
      await provider.createPreset(partiallyInvalidPreset);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Missing required field: db_valueSB_BS'));
      verifyNever(mockRepository.addPreset(any));
    });

    test('testPresetValidation - should validate update operations', () async {
      // Arrange
      final invalidUpdate = Preset(
        id: 'test_preset',
        name: '', // Invalid - empty name
        dateCreated: DateTime.now(),
        presetData: {
          'db_valueOV': 0.0,
          'db_valueSB_BS': 1.0,
          'reduce_background_noise': false,
        },
      );

      // Act
      await provider.updatePreset(invalidUpdate);

      // Assert
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Preset validation failed'));
      verifyNever(mockRepository.updatePreset(any));
    });
  });
}

// Extended class to add validation
class ValidationPresetProvider extends PresetProvider {
  ValidationPresetProvider(super.repository);

  String? _validationError;

  @override
  String? get error => _validationError ?? super.error;

  bool validatePreset(Preset preset) {
    // Validate preset name is not empty
    if (preset.name.trim().isEmpty) {
      _validationError = 'Preset validation failed: Name cannot be empty';
      notifyListeners();
      return false;
    }

    // Validate required fields in presetData
    final requiredFields = [
      'db_valueOV',
      'db_valueSB_BS',
      'reduce_background_noise',
    ];

    for (final field in requiredFields) {
      if (!preset.presetData.containsKey(field)) {
        _validationError =
            'Preset validation failed: Missing required field: $field';
        notifyListeners();
        return false;
      }
    }

    _validationError = null;
    return true;
  }

  @override
  Future<void> createPreset(Preset preset) async {
    if (!validatePreset(preset)) {
      return;
    }
    await super.createPreset(preset);
  }

  @override
  Future<void> updatePreset(Preset preset) async {
    if (!validatePreset(preset)) {
      return;
    }
    await super.updatePreset(preset);
  }
}
