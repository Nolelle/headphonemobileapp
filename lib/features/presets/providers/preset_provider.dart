import 'package:flutter/material.dart';
import '../models/preset.dart';
import '../repositories/preset_repository.dart';

class PresetProvider with ChangeNotifier {
  final PresetRepository _repository;
  Map<String, Preset> _presets = {};
  String? _activePresetId;
  bool _isLoading = false;
  String? _error;

  PresetProvider(this._repository);

  // Getters
  Map<String, Preset> get presets => _presets;
  String? get activePresetId => _activePresetId;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
    } catch (e) {
      _error = 'Failed to load presets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
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

  // Clear active preset
  void clearActivePreset() {
    _activePresetId = null;
    notifyListeners();
  }

  // Get preset by ID
  Preset? getPresetById(String id) => _presets[id];

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
