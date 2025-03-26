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

  Future<void> fetchSoundTests() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _soundTests = await _repository.getAllSoundTests();

      // If there are multiple profiles, keep only the most recent one
      if (_soundTests.length > 1) {
        final profiles = _soundTests.values.toList()
          ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));

        // Keep only the most recent profile
        final latestProfile = profiles.first;
        for (final profile in profiles.skip(1)) {
          await _repository.deleteSoundTest(profile.id);
        }

        _soundTests = {latestProfile.id: latestProfile};
      }

      // Set the active sound test ID to the only available one
      if (_soundTests.isNotEmpty) {
        _activeSoundTestId = _soundTests.keys.first;
      }

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

      // If there's already a profile, delete it first
      if (_soundTests.isNotEmpty) {
        for (final id in _soundTests.keys) {
          await _repository.deleteSoundTest(id);
        }
      }

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

      // Check if the sound test ID exists
      if (_soundTests.containsKey(soundTest.id)) {
        // Update the existing sound test
        await _repository.updateSoundTest(soundTest);
        _soundTests[soundTest.id] = soundTest;
      } else {
        // If sound test doesn't exist, but other tests exist, delete them
        if (_soundTests.isNotEmpty) {
          for (final id in _soundTests.keys) {
            await _repository.deleteSoundTest(id);
          }
          _soundTests.clear();
        }

        // Add the new sound test
        await _repository.addSoundTest(soundTest);
        _soundTests[soundTest.id] = soundTest;
      }

      // Set this as the active sound test
      _activeSoundTestId = soundTest.id;

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

      // We don't have a context here, so we use the default name
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
