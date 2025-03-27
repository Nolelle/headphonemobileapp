import 'package:flutter/material.dart';
import '../models/preset.dart';
import '../repositories/preset_repository.dart';
import '../../bluetooth/services/ble_data_service.dart';
import '../../sound_test/providers/sound_test_provider.dart';

class PresetProvider with ChangeNotifier {
  final PresetRepository _repository;
  Map<String, Preset> _presets = {};
  final Map<String, bool> _dropdownStates =
      {}; // Tracks dropdown states for presets
  String? _activePresetId;
  bool _isLoading = false;
  String? _error;
  final BLEDataService _bleDataService = BLEDataService();

  PresetProvider(this._repository);

  // Getters
  Map<String, Preset> get presets => _presets;
  String? get activePresetId => _activePresetId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get dropdownStates => _dropdownStates;

  // Get active preset
  Preset? get activePreset =>
      _activePresetId != null ? _presets[_activePresetId] : null;

  // Fetch all presets
  Future<void> fetchPresets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _presets = await _repository.getAllPresets();
      _initializeDropdownStates(); // Initialize dropdown states for all presets
    } catch (e) {
      _error = 'Failed to load presets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize dropdown states for presets
  void _initializeDropdownStates() {
    _dropdownStates.clear();
    for (var presetId in _presets.keys) {
      _dropdownStates[presetId] = false; // Default: all dropdowns closed
    }
  }

  // Create new preset
  Future<void> createPreset(Preset preset) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.addPreset(preset);
      await fetchPresets();
    } catch (e) {
      _error = 'Failed to create preset: $e';
      notifyListeners();
    }
  }

  // Update existing preset
  Future<void> updatePreset(Preset preset) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updatePreset(preset);
      await fetchPresets();
    } catch (e) {
      _error = 'Failed to update preset: $e';
      notifyListeners();
    }
  }

  // Delete preset
  Future<void> deletePreset(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deletePreset(id);
      _dropdownStates
          .remove(id); // Remove dropdown state for the deleted preset
      if (_activePresetId == id) {
        _activePresetId = null;
      }
      await fetchPresets();
    } catch (e) {
      _error = 'Failed to delete preset: $e';
      notifyListeners();
    }
  }

  // Set active preset
  void setActivePreset(String id) {
    if (_presets.containsKey(id)) {
      _activePresetId = id;
      notifyListeners();
    }
  }

  // Send the active preset to the connected device
  Future<bool> sendActivePresetToDevice() async {
    if (_activePresetId == null || !_presets.containsKey(_activePresetId!)) {
      return false;
    }

    try {
      final activePreset = _presets[_activePresetId!]!;
      return await _bleDataService.sendPresetData(activePreset);
    } catch (e) {
      print("Failed to send active preset to device: $e");
      return false;
    }
  }

  // Send combined preset and sound test data if available
  Future<bool> sendCombinedDataToDevice(
      SoundTestProvider soundTestProvider) async {
    if (_activePresetId == null || !_presets.containsKey(_activePresetId!)) {
      return false;
    }

    final activeSoundTest = soundTestProvider.activeSoundTest;
    if (activeSoundTest == null) {
      // If no active sound test, just send the preset
      return await sendActivePresetToDevice();
    }

    try {
      final activePreset = _presets[_activePresetId!]!;
      return await _bleDataService.sendCombinedData(
          activeSoundTest, activePreset);
    } catch (e) {
      print("Failed to send combined data to device: $e");
      return false;
    }
  }

  // Clear active preset
  void clearActivePreset() {
    _activePresetId = null;
    notifyListeners();
  }

  // Toggle dropdown visibility for a specific preset
  void toggleDropdown(String id, [bool? isOpen]) {
    if (_dropdownStates.containsKey(id)) {
      // If `isOpen` is provided, use it; otherwise, toggle the current state
      _dropdownStates[id] = isOpen ?? !_dropdownStates[id]!;
      notifyListeners();
    }
  }

  // Get preset by ID
  Preset? getPresetById(String id) => _presets[id];

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Alias for fetchPresets to maintain compatibility with main.dart
  Future<void> loadPresets() async {
    return fetchPresets();
  }
}
