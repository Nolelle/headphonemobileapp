import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/sound_test_provider.dart';
import '../../models/sound_test.dart';
import '../../../../l10n/app_localizations.dart';

class TestPage extends StatefulWidget {
  final String soundTestId;
  final String? soundTestName;
  final SoundTestProvider soundTestProvider;

  const TestPage({
    super.key,
    required this.soundTestId,
    this.soundTestName,
    required this.soundTestProvider,
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final TextEditingController _nameController = TextEditingController();
  String soundTest_name = '';
  double current_volume = 1.0;
  int current_sound_stage = 1;
  String current_ear = "";
  bool start_pressed = false;
  bool yes_hear_button_pressed = false;
  bool no_hear_button_pressed = false;
  double ear_balance = 0.0;
  bool test_completed = false;

  // Test measurements for left and right ear frequencies
  double L_user_250Hz_dB = 0.0;
  double L_user_500Hz_dB = 0.0;
  double L_user_1000Hz_dB = 0.0;
  double L_user_2000Hz_dB = 0.0;
  double L_user_4000Hz_dB = 0.0;

  double R_user_250Hz_dB = 0.0;
  double R_user_500Hz_dB = 0.0;
  double R_user_1000Hz_dB = 0.0;
  double R_user_2000Hz_dB = 0.0;
  double R_user_4000Hz_dB = 0.0;

  // Updated constants for proper dB SPL mapping
  final double MAX_DB_SPL = 85.0; // Maximum volume in dB SPL
  final double MIN_DB_SPL = 30.0; // Minimum volume in dB SPL
  final double INITIAL_DB_SPL = 65.0; // Starting volume in dB SPL
  final double STEP_DOWN_DB = 10.0; // Step down size in dB
  final double STEP_UP_DB = 5.0; // Step up size in dB

  final double MAX_VOLUME = 1.0;
  final double MIN_VOLUME = 0.01;
  final int TIMER_DURATION = 10;

  // Test state tracking
  bool is_finding_threshold = false;
  double last_heard_db = 0.0;
  int consecutive_not_heard = 0;

  bool is_sound_playing = false;

  final AudioPlayer frequency_player = AudioPlayer();
  final String _250Hz_audio = "audio/250Hz.wav";
  final String _500Hz_audio = "audio/500Hz.wav";
  final String _1000Hz_audio = "audio/1000Hz.wav";
  final String _2000Hz_audio = "audio/2000Hz.wav";
  final String _4000Hz_audio = "audio/4000Hz.wav";

  bool _isBluetoothConnected = false;
  final MethodChannel _bluetoothChannel =
      const MethodChannel('com.example.headphones/bluetooth');

  @override
  void initState() {
    super.initState();
    _loadExistingTestData();
    _checkBluetoothConnection();
    _initializeAudio();

    if (widget.soundTestName != null) {
      _nameController.text = widget.soundTestName!;
    }
  }

  void _loadExistingTestData() {
    final soundTest =
        widget.soundTestProvider.getSoundTestById(widget.soundTestId);
    if (soundTest != null) {
      setState(() {
        L_user_250Hz_dB = soundTest.soundTestData['L_user_250Hz_dB'] ?? 0.0;
        L_user_500Hz_dB = soundTest.soundTestData['L_user_500Hz_dB'] ?? 0.0;
        L_user_1000Hz_dB = soundTest.soundTestData['L_user_1000Hz_dB'] ?? 0.0;
        L_user_2000Hz_dB = soundTest.soundTestData['L_user_2000Hz_dB'] ?? 0.0;
        L_user_4000Hz_dB = soundTest.soundTestData['L_user_4000Hz_dB'] ?? 0.0;

        R_user_250Hz_dB = soundTest.soundTestData['R_user_250Hz_dB'] ?? 0.0;
        R_user_500Hz_dB = soundTest.soundTestData['R_user_500Hz_dB'] ?? 0.0;
        R_user_1000Hz_dB = soundTest.soundTestData['R_user_1000Hz_dB'] ?? 0.0;
        R_user_2000Hz_dB = soundTest.soundTestData['R_user_2000Hz_dB'] ?? 0.0;
        R_user_4000Hz_dB = soundTest.soundTestData['R_user_4000Hz_dB'] ?? 0.0;
<<<<<<< HEAD
        R_user_8000Hz_dB = soundTest.soundTestData['R_user_8000Hz_dB'] ?? 0.0;
=======
>>>>>>> d79eab9ba2351e153fcee6fc1b2f7e334ddb8621
      });
    }
  }

  Future<void> _initializeAudio() async {
    try {
      // Configure audio session for external playback
      // Use mediaPlayer mode which is better for Bluetooth devices
      await frequency_player.setPlayerMode(PlayerMode.mediaPlayer);

      debugPrint("Audio player initialized with mediaPlayer mode");

      // Force release any previously playing audio
      await frequency_player.stop();
      await frequency_player.release();

      // Set up error handling using onPlayerStateChanged
      frequency_player.onPlayerStateChanged.listen((state) {
        debugPrint("Audio player state changed: $state");
        // if (state == PlayerState.completed && is_sound_playing) {
        //   // If we're supposed to be playing but the sound completed, restart it
        //   // This conflicts with ReleaseMode.loop set in playFrequency
        //   // playFrequency(ear_balance);
        // }
        // TODO: Add other state handling if needed (e.g., error state)
      });
    } catch (e) {
      debugPrint("Error initializing audio: $e");
      if (mounted) {
        _showCustomToast(context,
            'Error setting up audio. Please check your earphones connection.');
      }
    }
  }

  @override
  void dispose() {
    try {
      // Ensure sound is stopped and set flag to prevent further usage
      is_sound_playing = false;

      // Complete cleanup of audio resources
      // Make these calls in a safer sequence to prevent race conditions
      frequency_player.onPlayerStateChanged
          .listen(null); // Remove listener first
      frequency_player.stop();
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          if (!mounted) {
            frequency_player.release();
            frequency_player.dispose();
            debugPrint("Audio player resources successfully released");
          }
        } catch (innerError) {
          debugPrint("Error in delayed cleanup: $innerError");
        }
      });
    } catch (e) {
      debugPrint("Error disposing audio player: $e");
    }

    _nameController.dispose();
    super.dispose();
  }

  double convertDBSPLToVolume(double dbSPL) {
    // Convert dB SPL to a volume value between 0 and 1
    // Using the formula: volume = 10^((dbSPL - MAX_DB_SPL)/20)
    return pow(10, (dbSPL - MAX_DB_SPL) / 20).toDouble().clamp(0.0, 1.0);
  }

  double convertVolumeToDBSPL(double volume) {
    // Convert volume (0-1) to dB SPL
    // Using the formula: dbSPL = 20 * log10(volume) + MAX_DB_SPL
    return (20 * log(volume) / ln10 + MAX_DB_SPL).clamp(MIN_DB_SPL, MAX_DB_SPL);
  }

  void updateFrequency_dB_Value() {
    double capturedVolume = current_volume;
    double dbValue = convertVolumeToDBSPL(capturedVolume);

    if (current_ear == "L") {
      switch (current_sound_stage) {
        case 1:
          debugPrint("Current volume for frequency: $capturedVolume");
          L_user_250Hz_dB = dbValue;
          break;
        case 2:
          L_user_500Hz_dB = dbValue;
          break;
        case 3:
          L_user_1000Hz_dB = dbValue;
          break;
        case 4:
          L_user_2000Hz_dB = dbValue;
          break;
        case 5:
          L_user_4000Hz_dB = dbValue;
          break;
      }
    } else if (current_ear == "R") {
      switch (current_sound_stage) {
        case 1:
          R_user_250Hz_dB = dbValue;
          break;
        case 2:
          R_user_500Hz_dB = dbValue;
          break;
        case 3:
          R_user_1000Hz_dB = dbValue;
          break;
        case 4:
          R_user_2000Hz_dB = dbValue;
          break;
        case 5:
          R_user_4000Hz_dB = dbValue;
          break;
      }
    }
    _saveSoundTest();
  }

  void updateCurrentEar() {
    setState(() {
      if (current_ear == "" && current_sound_stage == 1) {
        current_ear = "L";
        ear_balance = -1.0;
      } else if (current_ear == "L" && current_sound_stage > 5) {
        current_ear = "R";
        ear_balance = 1.0;
        current_sound_stage = 1;
      } else if (current_ear == "R" && current_sound_stage > 5) {
        current_ear = "";
        ear_balance = 0.0;
        test_completed = true;
        debugPrint("Hearing test completed for both ears");
        _handleTestCompletion();
      }
    });
  }

  void _handleTestCompletion() {
    try {
      // Stop playing sound and ensure complete cleanup
      frequency_player.stop();
      frequency_player.setReleaseMode(ReleaseMode.release);

      // Add a proper release call to free all resources
      frequency_player.release();

      // Additional cleanup & state management
      is_sound_playing = false;

      // Mark test as completed
      setState(() {
        test_completed = true;
      });

      // Save test data and show completion dialog
      _saveSoundTest();
    } catch (e) {
      debugPrint("Error during test completion: $e");
      // Still mark as completed even if there's an error
      setState(() {
        test_completed = true;
      });
      _saveSoundTest();
    }
  }

  Future<void> _saveSoundTest() async {
    final soundTest = SoundTest(
      id: widget.soundTestId,
      dateCreated: DateTime.now(),
      name: widget.soundTestName ?? 'Audio Profile',
      soundTestData: {
        'L_user_250Hz_dB': L_user_250Hz_dB,
        'L_user_500Hz_dB': L_user_500Hz_dB,
        'L_user_1000Hz_dB': L_user_1000Hz_dB,
        'L_user_2000Hz_dB': L_user_2000Hz_dB,
        'L_user_4000Hz_dB': L_user_4000Hz_dB,
        'R_user_250Hz_dB': R_user_250Hz_dB,
        'R_user_500Hz_dB': R_user_500Hz_dB,
        'R_user_1000Hz_dB': R_user_1000Hz_dB,
        'R_user_2000Hz_dB': R_user_2000Hz_dB,
        'R_user_4000Hz_dB': R_user_4000Hz_dB,
      },
      icon: Icons.hearing,
    );

    await widget.soundTestProvider.updateSoundTest(soundTest);
    if (mounted && test_completed) {
      _showTestCompletionDialog(context);
    }
  }

  void _showTestCompletionDialog(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.translate('test_complete')),
          content: Text(appLocalizations.translate('test_complete_message')),
          actions: [
            TextButton(
              onPressed: () {
                // First pop the dialog
                Navigator.of(context).pop();
                // Then pop the test page to return to sound test page
                Navigator.of(context).pop();
              },
              child: Text(appLocalizations.translate('ok')),
            ),
          ],
        );
      },
    );
  }

  void _showSaveConfirmationDialog(BuildContext context) {
    _showCustomToast(context, 'Value recorded');
  }

  void _showCustomToast(BuildContext context, String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: kToolbarHeight + 20,
        width: screenWidth,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: screenWidth * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: (screenWidth * 0.035).clamp(14.0, 18.0),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
<<<<<<< HEAD
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveSoundTest(IconData chosenIcon) async {
    final soundTest = SoundTest(
      id: widget.soundTestId,
      dateCreated: DateTime.now(),
      soundTestData: {
        'L_user_250Hz_dB': L_user_250Hz_dB,
        'L_user_500Hz_dB': L_user_500Hz_dB,
        'L_user_1000Hz_dB': L_user_1000Hz_dB,
        'L_user_2000Hz_dB': L_user_2000Hz_dB,
        'L_user_4000Hz_dB': L_user_4000Hz_dB,
        'L_user_8000Hz_dB': L_user_8000Hz_dB,
        'R_user_250Hz_dB': R_user_250Hz_dB,
        'R_user_500Hz_dB': R_user_500Hz_dB,
        'R_user_1000Hz_dB': R_user_1000Hz_dB,
        'R_user_2000Hz_dB': R_user_2000Hz_dB,
        'R_user_4000Hz_dB': R_user_4000Hz_dB,
        'R_user_8000Hz_dB': R_user_8000Hz_dB,
      },
=======
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
>>>>>>> d79eab9ba2351e153fcee6fc1b2f7e334ddb8621
    );

    overlay.insert(overlayEntry);

    // Remove the toast after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Color determineCurrentSoundStageBGColor(int soundStage, ThemeData theme) {
    if (soundStage == current_sound_stage) {
      return theme.brightness == Brightness.dark
          ? Colors.white70
          : Colors.white;
    }
    return theme.primaryColor;
  }

  Color determineCurrentSoundStageTextColor(int soundStage, ThemeData theme) {
    if (soundStage == current_sound_stage) {
      return theme.brightness == Brightness.dark
          ? Colors.black87
          : Colors.black54;
    }
    return Colors.white;
  }

  Future<void> playFrequency(double balance) async {
    try {
      debugPrint("AUDIO DEBUG: Starting playFrequency with balance: $balance");

      // Always test by playing a sound
      String currentFrequency = "";

      switch (current_sound_stage) {
        case 1:
          currentFrequency = _250Hz_audio;
          break;
        case 2:
          currentFrequency = _500Hz_audio;
          break;
        case 3:
          currentFrequency = _1000Hz_audio;
          break;
        case 4:
          currentFrequency = _2000Hz_audio;
          break;
        case 5:
          currentFrequency = _4000Hz_audio;
          break;
        default:
          // Handle unexpected sound stage by providing a default
          debugPrint(
              "AUDIO DEBUG: Invalid sound stage: $current_sound_stage, defaulting to 1000Hz");
          currentFrequency = _1000Hz_audio;
          break;
      }

      // Check if currentFrequency is empty or invalid
      if (currentFrequency.isEmpty) {
        throw Exception(
            "Invalid frequency selected. Sound stage: $current_sound_stage");
      }

      // Stop any currently playing audio
      await frequency_player.stop();
      is_sound_playing = false;

      debugPrint("AUDIO DEBUG: Playing frequency: $currentFrequency");
      debugPrint(
          "AUDIO DEBUG: Current volume: ${current_volume.toStringAsFixed(2)}");
      debugPrint(
          "AUDIO DEBUG: Current dB SPL: ${convertVolumeToDBSPL(current_volume).toStringAsFixed(1)}");

      // Set to mediaPlayer mode for better Bluetooth compatibility
      await frequency_player.setReleaseMode(ReleaseMode.loop);
      await frequency_player.setPlayerMode(PlayerMode.mediaPlayer);
      await frequency_player.setVolume(current_volume);

      // Small delay to ensure audio system is ready
      await Future.delayed(const Duration(milliseconds: 300));

      debugPrint("AUDIO DEBUG: About to call play() method");

      // Play the audio - using source path directly for more reliable loading
      final source = AssetSource(currentFrequency);
      debugPrint("AUDIO DEBUG: Asset source created: ${source.path}");

      try {
        await frequency_player.play(
          source,
          volume: current_volume,
          balance: balance,
        );

        debugPrint("AUDIO DEBUG: Successfully started playback");
        is_sound_playing = true;
      } catch (playError) {
        debugPrint("AUDIO DEBUG: Error during audio play: $playError");
        // Try again with simplified parameters
        try {
          debugPrint("AUDIO DEBUG: Trying simplified playback");
          await frequency_player.play(source);
          await frequency_player.setVolume(current_volume);
          is_sound_playing = true;
        } catch (retryError) {
          debugPrint("AUDIO DEBUG: Retry also failed: $retryError");
          rethrow;
        }
      }
    } catch (e) {
      debugPrint("AUDIO DEBUG: Error playing frequency: $e");
      if (mounted) {
        _showCustomToast(context, 'Error playing audio: $e');
      }
    }
  }

  void stopSound() {
    try {
      if (frequency_player.state != PlayerState.disposed) {
        frequency_player.stop();
        is_sound_playing = false;
        debugPrint("Sound stopped successfully");
      } else {
        debugPrint("Skipping stop command - player already disposed");
      }
    } catch (e) {
      debugPrint("Error stopping sound: $e");
    }
  }

  void setCurrentVolume(double newVolume) {
    setState(() {
      current_volume = newVolume;
    });
  }

  Future<void> decrementFrequencyVolume(AudioPlayer player) async {
    double currentDBSPL = convertVolumeToDBSPL(current_volume);
    double newDBSPL =
        (currentDBSPL - STEP_DOWN_DB).clamp(MIN_DB_SPL, MAX_DB_SPL);
    double newVolume = convertDBSPLToVolume(newDBSPL);

    debugPrint("Current dB SPL: ${currentDBSPL.toStringAsFixed(1)}");
    debugPrint("New dB SPL: ${newDBSPL.toStringAsFixed(1)}");

    setCurrentVolume(newVolume);
    await player.setVolume(newVolume);
  }

  Future<void> incrementFrequencyVolume(AudioPlayer player) async {
    double currentDBSPL = convertVolumeToDBSPL(current_volume);
    double newDBSPL = (currentDBSPL + STEP_UP_DB).clamp(MIN_DB_SPL, MAX_DB_SPL);
    double newVolume = convertDBSPLToVolume(newDBSPL);

    debugPrint("Current dB SPL: ${currentDBSPL.toStringAsFixed(1)}");
    debugPrint("New dB SPL: ${newDBSPL.toStringAsFixed(1)}");

    setCurrentVolume(newVolume);
    await player.setVolume(newVolume);
  }

  bool getYesHearButtonPressed() {
    debugPrint("\"I can hear it!\" was pressed.");
    return yes_hear_button_pressed;
  }

  void setYesHearButtonPressed(bool state) {
    yes_hear_button_pressed = state;
    getYesHearButtonPressed();
  }

  bool getNoHearButtonPressed() {
    debugPrint("\"I can not hear it!\" was pressed.");
    return no_hear_button_pressed;
  }

  void setNoHearButtonPressed(bool state) {
    no_hear_button_pressed = state;
    getNoHearButtonPressed();
  }

  void handleHearingTestSequence() {
    if (no_hear_button_pressed) {
      debugPrint(
          "User pressed 'Cannot Hear' at ${convertVolumeToDBSPL(current_volume).toStringAsFixed(1)} dB SPL");

      // Reset for next button press
      no_hear_button_pressed = false;

      if (!is_finding_threshold) {
        // First time they can't hear it - we found a potential threshold
        debugPrint(
            "First time user can't hear the tone - entering threshold finding phase");
        last_heard_db = convertVolumeToDBSPL(current_volume) + STEP_DOWN_DB;
        debugPrint(
            "Found potential threshold at ${last_heard_db.toStringAsFixed(1)} dB SPL");
        is_finding_threshold = true;

        // Show message about confirmation phase - keeping this toast as it's user guidance
        _showCustomToast(context,
            'Press "I can hear it" if you can hear the tone to confirm your threshold.');

        // Go back up 5dB
        incrementFrequencyVolume(frequency_player);
        debugPrint("Increased volume for confirmation");
      }
    } else if (yes_hear_button_pressed) {
      debugPrint(
          "User pressed 'Can Hear' at ${convertVolumeToDBSPL(current_volume).toStringAsFixed(1)} dB SPL");

      // Reset for next button press
      yes_hear_button_pressed = false;

      if (is_finding_threshold) {
        // User confirmed they can hear it - save the threshold
        updateFrequency_dB_Value();
        _showCustomToast(
            context,
            'Threshold confirmed for ${current_ear == "L" ? "Left" : "Right"} ear at ${current_sound_stage == 1 ? "250" : current_sound_stage == 2 ? "500" : current_sound_stage == 3 ? "1000" : current_sound_stage == 4 ? "2000" : "4000"}Hz: ${convertVolumeToDBSPL(current_volume).toStringAsFixed(1)} dB SPL');

        // Stop current tone
        stopSound();
        debugPrint("Moving to next frequency/ear");

        // Reset for next frequency
        setState(() {
          current_sound_stage++;
          is_finding_threshold = false;
          consecutive_not_heard = 0;
          last_heard_db = 0.0;
        });

        updateCurrentEar();

        // Check if test is complete before playing next frequency
        if (!test_completed) {
          // Start next frequency at initial volume
          setCurrentVolume(convertDBSPLToVolume(INITIAL_DB_SPL));
          playFrequency(ear_balance);
        } else {
          debugPrint("Test completed, not playing next frequency");
        }
      } else {
        // Still in initial descent - continue going down in steps
        decrementFrequencyVolume(frequency_player);
        debugPrint("Decreased volume to find threshold");
      }
    }
  }

  // Simple test function to try playing sound directly
  Future<void> _testPlayDirectSound() async {
    try {
      debugPrint("TEST AUDIO: Attempting to play 1kHz test tone directly");
      // Create a new player instance for testing
      final testPlayer = AudioPlayer();
      await testPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // Play with max volume
      await testPlayer.setVolume(1.0);

      await testPlayer.play(AssetSource('audio/1000Hz.wav'));
      debugPrint("TEST AUDIO: Play method completed");

      _showCustomToast(
          context, "Testing sound playback - you should hear a 1kHz tone");

      // Clean up after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      await testPlayer.stop();
      await testPlayer.dispose();
    } catch (e) {
      debugPrint("TEST AUDIO: Error in test play: $e");
      _showCustomToast(context, "Error testing audio: $e");
    }
  }

  void handleStartTest() {
    setState(() {
      start_pressed = true;
      debugPrint("Begin hearing test");
    });
    initializeTestSequence();
  }

  void initializeTestSequence() {
    setState(() {
      L_user_250Hz_dB = 0.0;
      L_user_500Hz_dB = 0.0;
      L_user_1000Hz_dB = 0.0;
      L_user_2000Hz_dB = 0.0;
      L_user_4000Hz_dB = 0.0;

      R_user_250Hz_dB = 0.0;
      R_user_500Hz_dB = 0.0;
      R_user_1000Hz_dB = 0.0;
      R_user_2000Hz_dB = 0.0;
      R_user_4000Hz_dB = 0.0;

      current_ear = "L";
      ear_balance = -1.0;
      current_sound_stage = 1;
      current_volume =
          convertDBSPLToVolume(INITIAL_DB_SPL); // Start at initial dB SPL
    });

    playFrequency(ear_balance);
  }

  Future<bool> _onWillPop() async {
    final appLocalizations = AppLocalizations.of(context);

    if (!start_pressed || test_completed) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(appLocalizations.translate('cancel_test')),
          content: Text(
            appLocalizations.translate('cancel_test_message'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(appLocalizations.translate('no_continue_test')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(appLocalizations.translate('yes_cancel')),
            ),
          ],
        );
      },
    );

    if (shouldPop ?? false) {
      // If the user decides to exit, reset to baseline values
      final defaultTest =
          SoundTest.defaultTest(widget.soundTestId, context: context);
      await widget.soundTestProvider.updateSoundTest(defaultTest);
    }

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black.withOpacity(0.87);
    final appLocalizations = AppLocalizations.of(context);

    // Replace WillPopScope with PopScope for better Android back button handling
    return PopScope(
      canPop: !start_pressed || test_completed,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            appLocalizations.translate('hearing_test'),
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: _buildActiveTestView(theme, textColor),
      ),
    );
  }

  Widget _buildActiveTestView(ThemeData theme, Color textColor) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safePadding = MediaQuery.of(context).padding;
    final availableHeight = screenHeight -
        AppBar().preferredSize.height -
        safePadding.top -
        safePadding.bottom;
    final appLocalizations = AppLocalizations.of(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Title
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          16.0, screenHeight * 0.02, 16.0, screenHeight * 0.01),
                      child: Text(
                        start_pressed
                            ? appLocalizations
                                .translate('hearing_test_in_progress')
                            : appLocalizations
                                .translate('prepare_for_hearing_test'),
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 28.0 : 22.0,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    if (!start_pressed) ...[
                      // Use the themed test instructions instead of plain text
                      Expanded(
                        child: Center(
                          child: _buildTestInstructions(),
                        ),
                      ),
                    ] else ...[
                      // Main content area with flexible spacing
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                              horizontal: screenWidth * 0.03),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Display ear indicator
                              _buildEarIdentifier(context, textColor),

                              // Display frequency stage
                              _buildFrequencyStageSelection(context, theme),

                              // Volume and buttons
                              _build_dB_AndButtons(context, theme),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudiogramChart() {
    final List<String> frequencies = [
      '250 Hz',
      '500 Hz',
      '1 kHz',
      '2 kHz',
      '4 kHz'
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final barMaxHeight = (screenHeight * 0.15).clamp(80.0, 150.0);
    final fontSize = (screenWidth * 0.022).clamp(8.0, 12.0);

    // Create lists for the left and right ear values
    final List<double> leftEarDBValues = [
      L_user_250Hz_dB.abs(),
      L_user_500Hz_dB.abs(),
      L_user_1000Hz_dB.abs(),
      L_user_2000Hz_dB.abs(),
      L_user_4000Hz_dB.abs(),
    ];

    final List<double> rightEarDBValues = [
      R_user_250Hz_dB.abs(),
      R_user_500Hz_dB.abs(),
      R_user_1000Hz_dB.abs(),
      R_user_2000Hz_dB.abs(),
      R_user_4000Hz_dB.abs(),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Legend
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Left Ear'),
                SizedBox(width: screenWidth * 0.05),
                _buildLegendItem(Colors.red, 'Right Ear'),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.008),

          // Chart area with extra padding
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, // Increased horizontal padding
                vertical: screenHeight * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  frequencies.length,
                  (index) {
                    final leftBarHeight =
                        (leftEarDBValues[index] / 60) * barMaxHeight;
                    final rightBarHeight =
                        (rightEarDBValues[index] / 60) * barMaxHeight;

                    // Calculate bar width with proper scaling
                    final barWidth = (screenWidth * 0.02).clamp(4.0, 10.0);
                    final columnWidth = screenWidth * 0.15;
                    final spaceBetweenBars = columnWidth - (barWidth * 2);

                    return Expanded(
                      flex: 3, // Give each column equal flex
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.015, // Increased padding
                          vertical: screenHeight * 0.01,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Use Row to position bars side by side
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Left ear bar with min height to ensure visibility
                                Container(
                                  height: leftBarHeight > 0
                                      ? max(leftBarHeight, 3.0)
                                      : 0,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(width: spaceBetweenBars / 3),
                                // Right ear bar with min height to ensure visibility
                                Container(
                                  height: rightBarHeight > 0
                                      ? max(rightBarHeight, 3.0)
                                      : 0,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Frequency label with better spacing
                            Container(
                              width: columnWidth,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.005),
                              child: Text(
                                frequencies[index],
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          width: (screenWidth * 0.03).clamp(10.0, 20.0),
          height: (screenWidth * 0.03).clamp(10.0, 20.0),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: screenWidth * 0.01),
        Text(
          label,
          style: TextStyle(
            fontSize: (screenWidth * 0.03).clamp(12.0, 16.0),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Build Start Button with better styling
  Widget _buildStartButton(BuildContext context, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final appLocalizations = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: handleStartTest,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            appLocalizations.translate('start_test'),
            style: TextStyle(
              color: Colors.white,
              fontSize: (screenWidth * 0.045).clamp(16.0, 22.0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Build I can hear / I cannot hear buttons with more visible styling
  Widget _build_dB_AndButtons(BuildContext context, ThemeData theme) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final appLocalizations = AppLocalizations.of(context);

    // Calculate scaling factors for adaptive UI
    final progressBarWidth = screenWidth * 0.75;
    final dbCardHeight = (screenHeight * 0.08).clamp(60.0, 100.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // dB display with Card
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.01),
          height: dbCardHeight,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.equalizer,
                size: (screenWidth * 0.08).clamp(24.0, 32.0),
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                "${convertVolumeToDBSPL(current_volume).toStringAsFixed(1)} dB",
                style: TextStyle(
                  fontSize: (screenWidth * 0.06).clamp(20.0, 28.0),
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Bluetooth connection icon
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!_isBluetoothConnected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bluetooth_disabled,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appLocalizations.translate('no_bluetooth'),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.amber,
                          fontSize: (screenWidth * 0.03).clamp(12.0, 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Buttons
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.015),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Yes button
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.02),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            yes_hear_button_pressed = true;
                            no_hear_button_pressed = false;
                          });
                          handleHearingTestSequence();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.018),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              appLocalizations.translate('i_can_hear_it'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    (screenWidth * 0.035).clamp(12.0, 16.0),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // No button
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.02),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            no_hear_button_pressed = true;
                            yes_hear_button_pressed = false;
                          });
                          handleHearingTestSequence();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.018),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              appLocalizations.translate('i_cannot_hear_it'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    (screenWidth * 0.035).clamp(12.0, 16.0),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarIdentifier(BuildContext context, Color textColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final appLocalizations = AppLocalizations.of(context);

    // Reduce container width to avoid text overflow
    final containerWidth = screenWidth * 0.4;
    final textSize = (screenWidth * 0.032).clamp(10.0, 16.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left ear container with fixed width
          Container(
            width: containerWidth,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: current_ear == "L"
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: current_ear == "L"
                    ? Colors.blue
                    : Colors.grey.withOpacity(0.3),
                width: current_ear == "L" ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  current_ear == "L" ? Icons.volume_up : Icons.volume_off,
                  size: textSize * 1.4,
                  color: current_ear == "L"
                      ? Colors.blue
                      : textColor.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    appLocalizations.translate('left_ear'),
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: current_ear == "L"
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: current_ear == "L"
                          ? Colors.blue
                          : textColor.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right ear container with fixed width
          Container(
            width: containerWidth,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: current_ear == "R"
                  ? Colors.red.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: current_ear == "R"
                    ? Colors.red
                    : Colors.grey.withOpacity(0.3),
                width: current_ear == "R" ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  current_ear == "R" ? Icons.volume_up : Icons.volume_off,
                  size: textSize * 1.4,
                  color: current_ear == "R"
                      ? Colors.red
                      : textColor.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    appLocalizations.translate('right_ear'),
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: current_ear == "R"
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: current_ear == "R"
                          ? Colors.red
                          : textColor.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFrequencyStageSelection(BuildContext context, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemSize = (screenWidth * 0.09)
        .clamp(36.0, 54.0); // Between 36-54px based on screen width
    final fontSize = (screenWidth * 0.04)
        .clamp(18.0, 24.0); // Between 18-24px based on screen width

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 8, horizontal: screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          final stageNumber = index + 1;
          return Container(
            height: itemSize,
            width: itemSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: determineCurrentSoundStageBGColor(stageNumber, theme),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              stageNumber.toString(),
              style: TextStyle(
                color: determineCurrentSoundStageTextColor(stageNumber, theme),
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<bool> _showResetConfirmationDialog(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Confirm Reset',
                style: TextStyle(
                  fontSize: (screenWidth * 0.05).clamp(18.0, 24.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Are you sure you want to reset to default values?',
                style: TextStyle(
                  fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                ),
              ),
              contentPadding: EdgeInsets.fromLTRB(screenWidth * 0.06,
                  screenWidth * 0.04, screenWidth * 0.06, screenWidth * 0.02),
              actionsPadding: EdgeInsets.all(screenWidth * 0.03),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.02),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.02),
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _checkBluetoothConnection() async {
    try {
      final bool isConnected =
          await _bluetoothChannel.invokeMethod('isBluetoothHeadsetConnected');
      setState(() {
        _isBluetoothConnected = isConnected;
      });

      if (!isConnected) {
        debugPrint("WARNING: No Bluetooth headset connected!");
        if (mounted) {
          _showCustomToast(context,
              'Please connect Bluetooth headphones for accurate test results');
        }
      } else {
        debugPrint("Bluetooth headset connected, proceeding with test");
      }
    } catch (e) {
      debugPrint("Error checking Bluetooth connection: $e");
      // Default to true to avoid blocking test
      setState(() {
        _isBluetoothConnected = true;
      });
    }
  }

  Widget _buildTestInstructions() {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appLocalizations.translate('some_instructions_before_starting'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildInstructionItem(
            appLocalizations.translate('sit_in_quiet_environment'),
            Icons.volume_off,
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            appLocalizations.translate('set_max_volume'),
            Icons.volume_up,
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            appLocalizations.translate('wear_headphones_properly'),
            Icons.headphones,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: handleStartTest,
            child: Text(
              appLocalizations.translate('begin_sound_test'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appLocalizations.translate('test_duration_minutes'),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}
