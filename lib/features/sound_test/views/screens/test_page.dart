import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../providers/sound_test_provider.dart';
import '../../models/sound_test.dart';

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

  final double MAX_VOLUME = 1.0;
  final double MIN_VOLUME = 0.01;
  final int TIMER_DURATION = 10;

  @override
  void initState() {
    super.initState();
    _loadExistingTestData();

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
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    frequency_player.dispose();
    super.dispose();
  }

  double convertVolumePercentTo_dB(double volume) {
    // Convert from percentage to dB SPL
    double dbSplVolume = 20 * log(volume);
    debugPrint("Volume in dB SPL: $dbSplVolume");
    return dbSplVolume;
  }

  void updateFrequency_dB_Value() {
    double capturedVolume = current_volume;
    double dbValue = convertVolumePercentTo_dB(capturedVolume);

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
        ear_balance = 0.0;
        _handleTestCompletion();
      }
    });
  }

  void _handleTestCompletion() {
    // Stop playing sound
    frequency_player.stop();
    frequency_player.setReleaseMode(ReleaseMode.release);

    // Mark test as completed
    setState(() {
      test_completed = true;
    });

    // Save test data and show completion dialog
    _saveSoundTest();
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Complete'),
          content:
              const Text('Your hearing test has been completed and saved.'),
          actions: [
            TextButton(
              onPressed: () {
                // First pop the dialog
                Navigator.of(context).pop();
                // Then pop the test page to return to sound test page
                Navigator.of(context).pop();
                // Show a success toast on the sound test page
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test results saved successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('OK'),
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
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the toast after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  double setCurrentEarTextSize(String selectedEar, double screenWidth) {
    double baseSize = screenWidth * 0.2; // 20% of screen width for main ear
    double inactiveSize =
        screenWidth * 0.08; // 8% of screen width for inactive ear

    if (selectedEar == current_ear) {
      return baseSize > 150.0 ? 150.0 : (baseSize < 100.0 ? 100.0 : baseSize);
    }
    return inactiveSize > 60.0
        ? 60.0
        : (inactiveSize < 40.0 ? 40.0 : inactiveSize);
  }

  double setCurrentEarIconSize(String selectedEar, double screenWidth) {
    double baseSize =
        screenWidth * 0.1; // 10% of screen width for main ear icon
    double inactiveSize =
        screenWidth * 0.04; // 4% of screen width for inactive ear icon

    if (selectedEar == current_ear) {
      return baseSize > 80.0 ? 80.0 : (baseSize < 60.0 ? 60.0 : baseSize);
    }
    return inactiveSize > 32.0
        ? 32.0
        : (inactiveSize < 24.0 ? 24.0 : inactiveSize);
  }

  IconData setCurrentEarIconDisplay(String selectedEar) {
    if (selectedEar == current_ear) {
      return Icons.volume_up;
    }
    return Icons.volume_off;
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

  final AudioPlayer frequency_player = AudioPlayer();
  final String _250Hz_audio = "audio/250Hz.wav";
  final String _500Hz_audio = "audio/500Hz.wav";
  final String _1000Hz_audio = "audio/1000Hz.wav";
  final String _2000Hz_audio = "audio/2000Hz.wav";
  final String _4000Hz_audio = "audio/4000Hz.wav";

  Future<void> playFrequency(double balance) async {
    await frequency_player.stop();
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
    }
    await frequency_player.setReleaseMode(ReleaseMode.loop);
    await frequency_player.play(
      AssetSource(currentFrequency),
      volume: current_volume,
      balance: balance,
    );

    debugPrint("Playing $currentFrequency at $current_volume dB");
  }

  void setCurrentVolume(double newVolume) {
    setState(() {
      current_volume = newVolume;
    });
  }

  Future<void> decrementFrequencyVolume(AudioPlayer player) async {
    double newVolume = current_volume - 0.05;
    debugPrint("Current volume: ${current_volume.toStringAsFixed(2)}");
    if (newVolume <= MIN_VOLUME) {
      newVolume = 0.01;
    }
    setCurrentVolume(newVolume);
    await player.setVolume(newVolume);
  }

  Future<void> incrementFrequencyVolume(AudioPlayer player) async {
    double newVolume = current_volume + 0.025;
    if (newVolume > MAX_VOLUME) {
      newVolume = MAX_VOLUME;
    }
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
    if (no_hear_button_pressed == true) {
      if (yes_hear_button_pressed == false && no_hear_button_pressed == true) {
        incrementFrequencyVolume(frequency_player);
      } else if (yes_hear_button_pressed == true) {
        updateFrequency_dB_Value();
        _showCustomToast(
            context,
            'Value recorded for ${current_ear == "L" ? "Left" : "Right"} ear at ${current_sound_stage == 1 ? "250" : current_sound_stage == 2 ? "500" : current_sound_stage == 3 ? "1000" : current_sound_stage == 4 ? "2000" : "4000"}Hz');
        setState(() {
          current_sound_stage++;
        });
        no_hear_button_pressed = false;
        yes_hear_button_pressed = false;
        updateCurrentEar();
        setCurrentVolume(1.00);
      }
    } else if (yes_hear_button_pressed == true) {
      if (current_volume == MIN_VOLUME) {
        updateFrequency_dB_Value();
        _showCustomToast(
            context,
            'Value recorded for ${current_ear == "L" ? "Left" : "Right"} ear at ${current_sound_stage == 1 ? "250" : current_sound_stage == 2 ? "500" : current_sound_stage == 3 ? "1000" : current_sound_stage == 4 ? "2000" : "4000"}Hz');
        setState(() {
          current_sound_stage++;
        });
        no_hear_button_pressed = false;
        yes_hear_button_pressed = false;
        updateCurrentEar();
        setCurrentVolume(1.00);
      } else {
        decrementFrequencyVolume(frequency_player);
        yes_hear_button_pressed = false;
      }
    }
    playFrequency(ear_balance);
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
      current_volume = 1.00;
    });

    playFrequency(ear_balance);
  }

  Future<bool> _onWillPop() async {
    if (!start_pressed || test_completed) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Test?'),
          content: const Text(
            'Are you sure you want to cancel the hearing test? Your progress will be lost.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, Continue Test'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black.withOpacity(0.87);

    return WillPopScope(
      onWillPop: _onWillPop,
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
          title: const Text(
            'Hearing Test',
            style: TextStyle(
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
                            ? 'Hearing Test In Progress'
                            : 'Prepare for Hearing Test',
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 28.0 : 22.0,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    if (!start_pressed) ...[
                      // Instructions with flexible spacing
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06,
                                vertical: screenHeight * 0.02),
                            child: Text(
                              'Find a quiet place for this test.\n\n'
                              'How the test works:\n'
                              '1. You will hear tones in each ear at different frequencies\n'
                              '2. Press "I can hear it!" when you first hear a sound\n'
                              '3. The volume will decrease and you should keep pressing "I can hear it!" until you can\'t hear it anymore\n'
                              '4. When you can\'t hear the sound anymore, press "I cannot hear it!"\n'
                              '5. If you press "I cannot hear it!" and then hear it again, press "I can hear it!"\n'
                              '6. This will record your hearing threshold for that frequency\n'
                              '7. The test will automatically move to the next frequency\n'
                              '8. This process repeats for all frequencies in both ears',
                              style: TextStyle(
                                fontSize: screenWidth > 600 ? 18.0 : 14.0,
                                color: textColor,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ),

                      // Start button with adaptive padding
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: screenHeight * 0.1,
                            top: screenHeight * 0.05,
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05),
                        child: _buildStartButton(context, theme),
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

          // Chart area
          Expanded(
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

                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.004),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Left ear bar with min height to ensure visibility
                          Container(
                            height: leftBarHeight > 0
                                ? max(leftBarHeight, 3.0)
                                : 0, // Minimum 3px height if value exists
                            width: (screenWidth * 0.015).clamp(4.0, 12.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          // Right ear bar with min height to ensure visibility
                          Container(
                            height: rightBarHeight > 0
                                ? max(rightBarHeight, 3.0)
                                : 0, // Minimum 3px height if value exists
                            width: (screenWidth * 0.015).clamp(4.0, 12.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          // Frequency label
                          Text(
                            frequencies[index],
                            style: TextStyle(fontSize: fontSize),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: ElevatedButton(
            onPressed: handleStartTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.025,
                  horizontal: screenWidth * 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            child: Text(
              "Begin Hearing Test",
              style: TextStyle(
                color: Colors.white,
                fontSize: (screenWidth * 0.05)
                    .clamp(18.0, 28.0), // Between 18-28px based on screen width
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Update the buttons display
  Widget _build_dB_AndButtons(BuildContext context, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // dB display
        Container(
          margin: EdgeInsets.only(bottom: screenHeight * 0.03),
          width: (screenWidth * 0.35).clamp(120.0, 180.0),
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.015, horizontal: screenWidth * 0.04),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            "${convertVolumePercentTo_dB(current_volume).toInt()} dB",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: (screenWidth * 0.06).clamp(20.0, 32.0),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
                          setYesHearButtonPressed(true);
                          handleHearingTestSequence();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'I can hear it!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (screenWidth * 0.04).clamp(16.0, 22.0),
                            fontWeight: FontWeight.bold,
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
                          setNoHearButtonPressed(true);
                          handleHearingTestSequence();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'I cannot hear it!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (screenWidth * 0.04).clamp(16.0, 22.0),
                            fontWeight: FontWeight.bold,
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                setCurrentEarIconDisplay("L"),
                size: setCurrentEarIconSize("L", screenWidth),
                color: textColor,
              ),
              const SizedBox(width: 4),
              Text(
                "L",
                style: TextStyle(
                  fontSize: setCurrentEarTextSize("L", screenWidth),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                setCurrentEarIconDisplay("R"),
                size: setCurrentEarIconSize("R", screenWidth),
                color: textColor,
              ),
              const SizedBox(width: 4),
              Text(
                "R",
                style: TextStyle(
                  fontSize: setCurrentEarTextSize("R", screenWidth),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
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
}
