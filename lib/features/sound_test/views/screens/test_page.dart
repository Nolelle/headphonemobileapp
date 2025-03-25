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
  late IconData chosen_icon = Icons.music_note;
  
  // Test measurements for left and right ear frequencies
  double L_user_250Hz_dB = 0.0;
  double L_user_500Hz_dB = 0.0;
  double L_user_1000Hz_dB = 0.0;
  double L_user_2000Hz_dB = 0.0;
  double L_user_4000Hz_dB = 0.0;
  double L_user_8000Hz_dB = 0.0;

  double R_user_250Hz_dB = 0.0;
  double R_user_500Hz_dB = 0.0;
  double R_user_1000Hz_dB = 0.0;
  double R_user_2000Hz_dB = 0.0;
  double R_user_4000Hz_dB = 0.0;
  double R_user_8000Hz_dB = 0.0;

  String current_ear = "";
  double ear_balance = 0.0;
  int current_sound_stage = 0;

  late double current_volume = 0.50;
  final double MAX_VOLUME = 1.0;
  final double MIN_VOLUME = 0.01;
  final int TIMER_DURATION = 10;

  bool yes_hear_button_pressed = false;
  bool no_hear_button_pressed = false;

  bool start_pressed = false;

  @override
  void initState() {
    super.initState();
    _loadExistingTestData();
    
    if (widget.soundTestName != null) {
      _nameController.text = widget.soundTestName!;
    }
  }

  void _loadExistingTestData() {
    final soundTest = widget.soundTestProvider.getSoundTestById(widget.soundTestId);
    if (soundTest != null) {
      setState(() {
        L_user_250Hz_dB = soundTest.soundTestData['L_user_250Hz_dB'] ?? 0.0;
        L_user_500Hz_dB = soundTest.soundTestData['L_user_500Hz_dB'] ?? 0.0;
        L_user_1000Hz_dB = soundTest.soundTestData['L_user_1000Hz_dB'] ?? 0.0;
        L_user_2000Hz_dB = soundTest.soundTestData['L_user_2000Hz_dB'] ?? 0.0;
        L_user_4000Hz_dB = soundTest.soundTestData['L_user_4000Hz_dB'] ?? 0.0;
        L_user_8000Hz_dB = soundTest.soundTestData['L_user_8000Hz_dB'] ?? 0.0;

        R_user_250Hz_dB = soundTest.soundTestData['R_user_250Hz_dB'] ?? 0.0;
        R_user_500Hz_dB = soundTest.soundTestData['R_user_500Hz_dB'] ?? 0.0;
        R_user_1000Hz_dB = soundTest.soundTestData['R_user_1000Hz_dB'] ?? 0.0;
        R_user_2000Hz_dB = soundTest.soundTestData['R_user_2000Hz_dB'] ?? 0.0;
        R_user_4000Hz_dB = soundTest.soundTestData['R_user_4000Hz_dB'] ?? 0.0;
        R_user_8000Hz_dB = soundTest.soundTestData['R_user_8000Hz_dB'] ?? 0.0;
        
        if (soundTest.icon != null) {
          chosen_icon = soundTest.icon;
        }
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
    double dB_SPL_volume = 20 * log(volume);
    debugPrint("Volume in dB SPL: $dB_SPL_volume");
    return dB_SPL_volume;
  }

  void updateFrequency_dB_Value() {
    double captured_volume = current_volume;
    double db_value = convertVolumePercentTo_dB(captured_volume);
    
    if (current_ear == "L") {
      switch (current_sound_stage) {
        case 1:
          debugPrint("Current volume for frequency: $captured_volume");
          L_user_250Hz_dB = db_value;
          break;
        case 2:
          L_user_500Hz_dB = db_value;
          break;
        case 3:
          L_user_1000Hz_dB = db_value;
          break;
        case 4:
          L_user_2000Hz_dB = db_value;
          break;
        case 5:
          L_user_4000Hz_dB = db_value;
          break;
        case 6:
          L_user_8000Hz_dB = db_value;
          break;
      }
    } else if (current_ear == "R") {
      switch (current_sound_stage) {
        case 1:
          R_user_250Hz_dB = db_value;
          break;
        case 2:
          R_user_500Hz_dB = db_value;
          break;
        case 3:
          R_user_1000Hz_dB = db_value;
          break;
        case 4:
          R_user_2000Hz_dB = db_value;
          break;
        case 5:
          R_user_4000Hz_dB = db_value;
          break;
        case 6:
          R_user_8000Hz_dB = db_value;
          break;
      }
    }
    _saveSoundTest(chosen_icon);
  }

  void updateCurrentEar() {
    setState(() {
      if (current_ear == "" && current_sound_stage == 1) {
        current_ear = "L";
        ear_balance = -1.0;
      } else if (current_ear == "L" && current_sound_stage > 6) {
        current_ear = "R";
        ear_balance = 1.0;
        current_sound_stage = 1;
      } else if (current_ear == "R" && current_sound_stage > 6) {
        ear_balance = 0.0;
        _showTestCompletionDialog(context);
      }
    });
  }

  void _showTestCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Completed'),
          content: const Text('The test has been recorded successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _showProfileCreationDialog(context); // Show the profile creation dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileCreationDialog(BuildContext context) {
    IconData selectedIcon = chosen_icon; // Use current icon
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Name Your Profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Audio Profile Name',
                      hintText: 'Enter a name for your audio profile',
                    ),
                    onChanged: (_) {
                      // No immediate save on text change
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Choose an Icon:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home),
                        onPressed: () {
                          setState(() {
                            selectedIcon = Icons.home;
                            chosen_icon = selectedIcon;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.music_note),
                        onPressed: () {
                          setState(() {
                            selectedIcon = Icons.music_note;
                            chosen_icon = selectedIcon;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.hearing),
                        onPressed: () {
                          setState(() {
                            selectedIcon = Icons.hearing;
                            chosen_icon = selectedIcon;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _saveSoundTest(selectedIcon);
                    
                    debugPrint("Volume for frequencies:"
                        "\n-----------------------"
                        "\nLeft 250Hz: $L_user_250Hz_dB"
                        "\nLeft 500Hz: $L_user_500Hz_dB"
                        "\nLeft 1000Hz: $L_user_1000Hz_dB"
                        "\nLeft 2000Hz: $L_user_2000Hz_dB"
                        "\nLeft 4000Hz: $L_user_4000Hz_dB"
                        "\nLeft 8000Hz: $L_user_8000Hz_dB"
                        "\nRight 250Hz: $R_user_250Hz_dB"
                        "\nRight 500Hz: $R_user_500Hz_dB"
                        "\nRight 1000Hz: $R_user_1000Hz_dB"
                        "\nRight 2000Hz: $R_user_2000Hz_dB"
                        "\nRight 4000Hz: $R_user_4000Hz_dB"
                        "\nRight 8000Hz: $R_user_8000Hz_dB"
                        "");

                    Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the first route
                  },
                  child: const Text('Save'),
                ),
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
      name: _nameController.text.isNotEmpty ? _nameController.text : widget.soundTestName,
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
      icon: chosenIcon,
    );

    await widget.soundTestProvider.updateSoundTest(soundTest);
  }

  double setCurrentEarTextSize(String selectedEar) {
    if (selectedEar == current_ear) {
      return 125.0;
    }
    return 45.0;
  }

  double setCurrentEarIconSize(String selectedEar) {
    if (selectedEar == current_ear) {
      return 60.0;
    }
    return 24.0;
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
  final String _8000Hz_audio = "audio/8000Hz.wav";

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
      case 6:
        currentFrequency = _8000Hz_audio;
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

  void setCurrentVolume(double new_volume) {
    setState(() {
      current_volume = new_volume;
    });
  }

  Future<void> decrementFrequencyVolume(AudioPlayer player) async {
    double new_volume = current_volume - 0.05;
    debugPrint("Current volume: ${current_volume.toStringAsFixed(2)}");
    if (new_volume <= MIN_VOLUME) {
      new_volume = 0.01;
    }
    setCurrentVolume(new_volume);
    await player.setVolume(new_volume);
  }

  Future<void> incrementFrequencyVolume(AudioPlayer player) async {
    double new_volume = current_volume + 0.025;
    if (new_volume > MAX_VOLUME) {
      new_volume = MAX_VOLUME;
    }
    setCurrentVolume(new_volume);
    await player.setVolume(new_volume);
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
      L_user_8000Hz_dB = 0.0;

      R_user_250Hz_dB = 0.0;
      R_user_500Hz_dB = 0.0;
      R_user_1000Hz_dB = 0.0;
      R_user_2000Hz_dB = 0.0;
      R_user_4000Hz_dB = 0.0;
      R_user_8000Hz_dB = 0.0;

      current_ear = "L";
      ear_balance = -1.0;
      current_sound_stage = 1;
      current_volume = 1.00;
    });

    playFrequency(ear_balance);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Cancel Test?"),
                  content:
                      const Text("Are you sure you want to cancel the test?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Stop audio
                        frequency_player.stop();
                        frequency_player.setReleaseMode(ReleaseMode.release);
                        
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Go back to the previous screen
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: const Text(
          'Sound Test',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 12.5),
              child: Column(
                children: [
                  Text(
                    "Click the button below when you hear the sound. This will record the volume at which you can hear the frequency.",
                    style: TextStyle(
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEarIdentifier(context, textColor),
                _buildFrequencyStageSelection(context, theme),
                start_pressed ? _build_dB_AndButtons(context, theme) : _buildStartButton(context, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarIdentifier(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                setCurrentEarIconDisplay("L"),
                size: setCurrentEarIconSize("L"),
                color: textColor,
              ),
              Text(
                "L",
                style: TextStyle(
                  fontSize: setCurrentEarTextSize("L"),
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
                size: setCurrentEarIconSize("R"),
                color: textColor,
              ),
              Text(
                "R",
                style: TextStyle(
                  fontSize: setCurrentEarTextSize("R"),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 35,
            width: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: determineCurrentSoundStageBGColor(1, theme),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "1",
              style: TextStyle(
                color: determineCurrentSoundStageTextColor(1, theme),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            height: 35,
            width: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: determineCurrentSoundStageBGColor(2, theme),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "2",
              style: TextStyle(
                color: determineCurrentSoundStageTextColor(2, theme),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            height: 35,
            width: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: determineCurrentSoundStageBGColor(3, theme),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "3",
              style: TextStyle(
                color: determineCurrentSoundStageTextColor(3, theme),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            height: 35,
            width: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: determineCurrentSoundStageBGColor(4, theme),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "4",
              style: TextStyle(
                color: determineCurrentSoundStageTextColor(4, theme),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            height: 35,
            width: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: determineCurrentSoundStageBGColor(5, theme),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "5",
              style: TextStyle(
                color: determineCurrentSoundStageTextColor(5, theme),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            height: 35,
            width: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: determineCurrentSoundStageBGColor(6, theme),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "6",
              style: TextStyle(
                color: determineCurrentSoundStageTextColor(6, theme),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              handleStartTest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18.75, horizontal: 25),
            ),
            child: const Text(
              "Begin Test",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build_dB_AndButtons(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${convertVolumePercentTo_dB(current_volume).toInt()} dB",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setYesHearButtonPressed(true);
                  handleHearingTestSequence();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: const Text(
                  'I can hear it!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setNoHearButtonPressed(true);
                  handleHearingTestSequence();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: const Text(
                  'I can not hear it!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}