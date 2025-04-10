// Mocks generated by Mockito 5.4.5 from annotations
// in projects/test/unit/mocks/mock_preset_provider.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:ui' as _i6;

import 'package:mockito/mockito.dart' as _i1;
import 'package:projects/features/presets/models/preset.dart' as _i3;
import 'package:projects/features/presets/providers/preset_provider.dart'
    as _i2;
import 'package:projects/features/presets/repositories/preset_repository.dart'
    as _i7;
import 'package:projects/features/sound_test/providers/sound_test_provider.dart'
    as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [PresetProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockPresetProvider extends _i1.Mock implements _i2.PresetProvider {
  MockPresetProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Map<String, _i3.Preset> get presets =>
      (super.noSuchMethod(
            Invocation.getter(#presets),
            returnValue: <String, _i3.Preset>{},
          )
          as Map<String, _i3.Preset>);

  @override
  bool get isLoading =>
      (super.noSuchMethod(Invocation.getter(#isLoading), returnValue: false)
          as bool);

  @override
  Map<String, bool> get dropdownStates =>
      (super.noSuchMethod(
            Invocation.getter(#dropdownStates),
            returnValue: <String, bool>{},
          )
          as Map<String, bool>);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i4.Future<void> fetchPresets() =>
      (super.noSuchMethod(
            Invocation.method(#fetchPresets, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> createPreset(_i3.Preset? preset) =>
      (super.noSuchMethod(
            Invocation.method(#createPreset, [preset]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> updatePreset(_i3.Preset? preset) =>
      (super.noSuchMethod(
            Invocation.method(#updatePreset, [preset]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> deletePreset(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#deletePreset, [id]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void setActivePreset(String? id) => super.noSuchMethod(
    Invocation.method(#setActivePreset, [id]),
    returnValueForMissingStub: null,
  );

  @override
  _i4.Future<bool> sendActivePresetToDevice() =>
      (super.noSuchMethod(
            Invocation.method(#sendActivePresetToDevice, []),
            returnValue: _i4.Future<bool>.value(false),
          )
          as _i4.Future<bool>);

  @override
  _i4.Future<bool> sendCombinedDataToDevice(
    _i5.SoundTestProvider? soundTestProvider,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#sendCombinedDataToDevice, [soundTestProvider]),
            returnValue: _i4.Future<bool>.value(false),
          )
          as _i4.Future<bool>);

  @override
  void clearActivePreset() => super.noSuchMethod(
    Invocation.method(#clearActivePreset, []),
    returnValueForMissingStub: null,
  );

  @override
  void toggleDropdown(String? id, [bool? isOpen]) => super.noSuchMethod(
    Invocation.method(#toggleDropdown, [id, isOpen]),
    returnValueForMissingStub: null,
  );

  @override
  _i3.Preset? getPresetById(String? id) =>
      (super.noSuchMethod(Invocation.method(#getPresetById, [id]))
          as _i3.Preset?);

  @override
  void clearError() => super.noSuchMethod(
    Invocation.method(#clearError, []),
    returnValueForMissingStub: null,
  );

  @override
  _i4.Future<void> loadPresets() =>
      (super.noSuchMethod(
            Invocation.method(#loadPresets, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void addListener(_i6.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i6.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [PresetRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockPresetRepository extends _i1.Mock implements _i7.PresetRepository {
  MockPresetRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<Map<String, _i3.Preset>> getAllPresets() =>
      (super.noSuchMethod(
            Invocation.method(#getAllPresets, []),
            returnValue: _i4.Future<Map<String, _i3.Preset>>.value(
              <String, _i3.Preset>{},
            ),
          )
          as _i4.Future<Map<String, _i3.Preset>>);

  @override
  _i4.Future<void> saveAllPresets(Map<String, _i3.Preset>? presets) =>
      (super.noSuchMethod(
            Invocation.method(#saveAllPresets, [presets]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> addPreset(_i3.Preset? preset) =>
      (super.noSuchMethod(
            Invocation.method(#addPreset, [preset]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> updatePreset(_i3.Preset? preset) =>
      (super.noSuchMethod(
            Invocation.method(#updatePreset, [preset]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> deletePreset(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#deletePreset, [id]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);
}
