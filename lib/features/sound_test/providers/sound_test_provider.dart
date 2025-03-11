import 'package:flutter/material.dart';
import '../models/sound_test.dart';
import '../repositories/sound_test_repository.dart';

class SoundTestProvider with ChangeNotifier {
  final SoundTestRepository _repository;
  Map<String, SoundTest> _soundTests = {};
  String? _activeSoundTestId;
  bool _isLoading = false;
  String? _error;

  SoundTestProvider(this._repository);

  // Getters
  Map<String, SoundTest> get soundTests => _soundTests;
  String? get activeSoundTestId => _activeSoundTestId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SoundTest? get activeSoundTest =>
      _activeSoundTestId != null ? _soundTests[_activeSoundTestId] : null;

  // Fetch all sound tests
  Future<void> fetchSoundTests() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _soundTests = await _repository.getAllSoundTests();
    } catch (e) {
      _error = 'Failed to load sound tests: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new sound test
  Future<void> createSoundTest(SoundTest soundTest) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.addSoundTest(soundTest);
      await fetchSoundTests();
    } catch (e) {
      _error = 'Failed to create sound test: $e';
      notifyListeners();
    }
  }

  //while for presets, its meant to update the existing one, itll work the same way, its just you cant change it afterwards, might change that tho
  Future<void> updateSoundTest(SoundTest soundTest) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateSoundTest(soundTest);
      await fetchSoundTests();
    } catch (e) {
      _error = 'Failed to update sound test: $e';
      notifyListeners();
    }
  }

  // Delete sound test
  Future<void> deleteSoundTest(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteSoundTest(id);
      if (_activeSoundTestId == id) {
        _activeSoundTestId = null;
      }
      await fetchSoundTests();
    } catch (e) {
      _error = 'Failed to delete sound test: $e';
      notifyListeners();
    }
  }

  // Set active sound test
  void setActiveSoundTest(String id) {
    if (_soundTests.containsKey(id)) {
      _activeSoundTestId = id;
      notifyListeners();
    }
  }

  // Clear active sound test
  void clearActiveSoundTest() {
    _activeSoundTestId = null;
    notifyListeners();
  }

  SoundTest? getSoundTestById(String id) => _soundTests[id];

  void clearError() {
    _error = null;
    notifyListeners();
  }
}