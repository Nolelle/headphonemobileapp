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

  SoundTest? get activeSoundTest => _activeSoundTestId != null
      ? _soundTests[_activeSoundTestId]
      : null;

  Future<void> fetchSoundTests() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _soundTests = await _repository.getAllSoundTests();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load sound tests: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> updateSoundTest(SoundTest soundTest) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateSoundTest(soundTest);
      _soundTests[soundTest.id] = soundTest;

      if (_activeSoundTestId == null || _activeSoundTestId == soundTest.id) {
        _activeSoundTestId = soundTest.id;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update sound test: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetSoundTest(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final soundTest = SoundTest.defaultTest(id);
      await _repository.updateSoundTest(soundTest);
      _soundTests[id] = soundTest;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset sound test: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveSoundTest(String id) {
    if (_soundTests.containsKey(id)) {
      _activeSoundTestId = id;
      notifyListeners();
    }
  }

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