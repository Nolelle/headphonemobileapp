import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../providers/sound_test_provider.dart';
import '../../models/sound_test.dart';

class TestPage extends StatefulWidget {
  final String soundTestId;
  final String soundTestName;
  final SoundTestProvider soundTestProvider;

  const TestPage({
    super.key,
    required this.soundTestId,
    required this.soundTestName,
    required this.soundTestProvider,
  });

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late TextEditingController _nameController;
  late IconData chosen_icon = Icons.home;
  double L_band_1_dB = 0.0;
  double L_band_2_dB = 0.0;
  double L_band_3_dB = 0.0;
  double L_band_4_dB = 0.0;
  double L_band_5_dB = 0.0;

  double R_band_1_dB = 0.0;
  double R_band_2_dB = 0.0;
  double R_band_3_dB = 0.0;
  double R_band_4_dB = 0.0;
  double R_band_5_dB = 0.0;

  String current_ear = "";
  double ear_balance = 0.0; //-1.0 for left, 0.0 for both, 1.0 for right
  int current_sound_stage = 0;

  late double current_volume = 0.50; //actually, we're just converting it instead
  final double MAX_VOLUME = 1.0;
  final double MIN_VOLUME = 0.01;
  final int TIMER_DURATION = 10;

  bool yes_hear_button_pressed = false;
  bool no_hear_button_pressed = false;

  bool start_pressed = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.soundTestName);
  }

  @override
  void dispose() {
    super.dispose();
  }

  double volumePercentageToDB(volume) {
    return 0;
  }

  double convertVolumePercentTo_dB(volume) {
    double dB_SPL_volume = 20 * log(volume);
    debugPrint("Volume in dB SPL: $dB_SPL_volume");
    return dB_SPL_volume;
  }

  void updateFrequency_dB_Value() {
    double captured_volume = convertVolumePercentTo_dB(current_volume);
    if (current_ear == "L") {
      switch (current_sound_stage) {
        case 1:
          L_band_1_dB = captured_volume;
          break;
        case 2:
          L_band_2_dB = captured_volume;
          break;
        case 3:
          L_band_3_dB = captured_volume;
          break;
        case 4:
          L_band_4_dB = captured_volume;
          break;
        case 5:
          L_band_5_dB = captured_volume;
          break;
      }
    }
    else if (current_ear == "R") {
      switch (current_sound_stage) {
        case 1:
          R_band_1_dB = captured_volume;
          break;
        case 2:
          R_band_2_dB = captured_volume;
          break;
        case 3:
          R_band_3_dB = captured_volume;
          break;
        case 4:
          R_band_4_dB = captured_volume;
          break;
        case 5:
          R_band_5_dB = captured_volume;
          break;
      }
    }
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
                // Navigator.pop(context); // Close the dialog
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
                      chosen_icon = Icons.home;
                      _saveSoundTest();
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
                            chosen_icon = Icons.home;
                            _saveSoundTest();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.music_note),
                        onPressed: () {
                          setState(() {
                            chosen_icon = Icons.music_note;
                            _saveSoundTest();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.hearing),
                        onPressed: () {
                          setState(() {
                            chosen_icon = Icons.hearing;
                            _saveSoundTest();
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
                    debugPrint("Volume for frequencies:"
                        "\n-----------------------"
                        "\nLeft band 1: $L_band_1_dB"
                        "\nLeft band 2: $L_band_2_dB"
                        "\nLeft band 3: $L_band_3_dB"
                        "\nLeft band 4: $L_band_4_dB"
                        "\nLeft band 5: $L_band_5_dB"
                        "\nRight band 1: $R_band_1_dB"
                        "\nRight band 2: $R_band_2_dB"
                        "\nRight band 3: $R_band_3_dB"
                        "\nRight band 4: $R_band_4_dB"
                        "\nRight band 5: $R_band_5_dB"
                        "");
                    Navigator.of(context).popUntil((route) => route.isFirst);
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

  Future<void> _saveSoundTest() async {
    final soundTest = SoundTest(
      id: widget.soundTestId,
      name: _nameController.text,
      dateCreated: DateTime.now(),
      soundTestData: {
        'L_band_1_dB': L_band_1_dB,
        'L_band_2_dB': L_band_2_dB,
        'L_band_3_dB': L_band_3_dB,
        'L_band_4_dB': L_band_4_dB,
        'L_band_5_dB': L_band_5_dB,
        'R_band_1_dB': R_band_1_dB,
        'R_band_2_dB': R_band_2_dB,
        'R_band_3_dB': R_band_3_dB,
        'R_band_4_dB': R_band_4_dB,
        'R_band_5_dB': R_band_5_dB,
      },
      icon: chosen_icon,
    );

    await widget.soundTestProvider.updateSoundTest(soundTest);
  }

  double setCurrentEarTextSize(String selected_ear) {
    if (selected_ear == current_ear) {
      return 125.0;
    }
    return 45.0;
  }
  double setCurrentEarIconSize(String selected_ear) {
    if (selected_ear == current_ear) {
      return 60.0;
    }
    return 24.0;
  }
  IconData setCurrentEarIconDisplay(String selected_ear) {
    if (selected_ear == current_ear) {
      return Icons.volume_up;
    }
    return Icons.volume_off;
  }
  Color determineCurrentSoundStageBGColor(int sound_stage) {
    if (sound_stage == current_sound_stage) {
      return Color.fromRGBO(255, 255, 255, 1.0);
    }
    return Color.fromRGBO(133, 86, 169, 1.0);
  }
  Color determineCurrentSoundStageTextColor(int sound_stage) {
    if (sound_stage == current_sound_stage) {
      return Colors.black54;
    }
    return Colors.white;
  }

  //TODO
  final AudioPlayer frequency_player = AudioPlayer();
  final String _band_1_audio = "audio/250Hz.wav";
  final String _band_2_audio = "audio/500Hz.wav";
  final String _band_3_audio = "audio/1000Hz.wav";
  final String _band_4_audio = "audio/2000Hz.wav";
  final String _band_5_audio = "audio/4000Hz.wav";

  Future<void> playFrequency(double balance) async {
    await frequency_player.stop();
    String current_frequency = "";

    switch (current_sound_stage) {
      case 1:
        current_frequency = _band_1_audio;
        break;
      case 2:
        current_frequency = _band_2_audio;
        break;
      case 3:
        current_frequency = _band_3_audio;
        break;
      case 4:
        current_frequency = _band_4_audio;
        break;
      case 5:
        current_frequency = _band_5_audio;
        break;
    }
    await frequency_player.setReleaseMode(ReleaseMode.loop);
    await frequency_player.play(
      AssetSource(current_frequency),
      volume: current_volume,
      balance: balance,
    );

    debugPrint("Playing $current_frequency at $current_volume dB");
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
      }
      else if (yes_hear_button_pressed == true) {
        updateFrequency_dB_Value();
        setState(() {
          current_sound_stage++;
        });
        no_hear_button_pressed = false;
        yes_hear_button_pressed = false;
        updateCurrentEar();
        setCurrentVolume(1.00);
      }
    }
    else if (yes_hear_button_pressed == true) {
      if (current_volume == MIN_VOLUME) {
        updateFrequency_dB_Value();
        setState(() {
          current_sound_stage++;
        });
        no_hear_button_pressed = false;
        yes_hear_button_pressed = false;
        updateCurrentEar();
        setCurrentVolume(1.00);
      }
      else {
        decrementFrequencyVolume(frequency_player);
        yes_hear_button_pressed = false;
      }
    }
    playFrequency(ear_balance);
  }

  void handleStartTest() {
    setState(() {
      start_pressed = true; // Set the flag to indicate the test has started
      debugPrint("Begin hearing test");
    });
    initializeTestSequence();
  }

  void initializeTestSequence() {
    current_ear = "L";
    ear_balance = -1.0;
    current_sound_stage = 1;
    current_volume = 1.00;

    playFrequency(ear_balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Cancel Test?"),
                  content: const Text("Are you sure you want to cancel the test?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(), // Close dialog
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12.5),
              child: Column(
                children: [
                  Text(
                    "Click the button below when you hear the sound. This will record the volume at which you can hear the frequency.",
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                ],
              ),
            ),
            // Actual hearing test part
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEarIdentifier(context),
                _buildFrequencyStageSelection(context),
                start_pressed ? _build_dB_AndButtons(context) : _buildStartButton(context), // Conditionally render buttons
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarIdentifier(BuildContext context) {
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
                ),
                Text(
                  "L",
                  style: TextStyle(
                      fontSize: setCurrentEarTextSize("L"),
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  setCurrentEarIconDisplay("R"),
                  size: setCurrentEarIconSize("R"),
                ),
                Text(
                  "R",
                  style: TextStyle(
                      fontSize: setCurrentEarTextSize("R"),
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            )
          ],
        )
    );
  }

  Widget _buildFrequencyStageSelection(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 35,
                  width: 35,
                  alignment: Alignment.center, // Centers text
                  decoration: BoxDecoration(
                    color: determineCurrentSoundStageBGColor(1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "1",
                    style: TextStyle(
                      color: determineCurrentSoundStageTextColor(1),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  width: 35,
                  alignment: Alignment.center, // Centers text
                  decoration: BoxDecoration(
                    color: determineCurrentSoundStageBGColor(2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "2",
                    style: TextStyle(
                      color: determineCurrentSoundStageTextColor(2),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  width: 35,
                  alignment: Alignment.center, // Centers text
                  decoration: BoxDecoration(
                    color: determineCurrentSoundStageBGColor(3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "3",
                    style: TextStyle(
                      color: determineCurrentSoundStageTextColor(3),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  width: 35,
                  alignment: Alignment.center, // Centers text
                  decoration: BoxDecoration(
                    color: determineCurrentSoundStageBGColor(4),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "4",
                    style: TextStyle(
                      color: determineCurrentSoundStageTextColor(4),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  height: 35,
                  width: 35,
                  alignment: Alignment.center, // Centers text
                  decoration: BoxDecoration(
                    color: determineCurrentSoundStageBGColor(5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "5",
                    style: TextStyle(
                      color: determineCurrentSoundStageTextColor(5),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              handleStartTest();
            }, // Call handleStartTest without parentheses
            child: const Text("Begin Test"),
          ),
        ],
      ),
    );
  }

  Widget _build_dB_AndButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: 100, // Set a fixed width for the background
            padding: EdgeInsets.all(8), // Add padding to create thickness around the text
            decoration: BoxDecoration(
              color: Color.fromRGBO(133, 86, 169, 1.0), // Set the background color
              borderRadius: BorderRadius.circular(12), // Add rounded corners
            ),
            child: Text(
              "${convertVolumePercentTo_dB(current_volume).toInt()} dB",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center, // Center the text within the container
            ),
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setYesHearButtonPressed(true);
                  handleHearingTestSequence();
                },
                child: const Text('I can hear it!'),
              ),
              ElevatedButton(
                onPressed: () {
                  setNoHearButtonPressed(true);
                  handleHearingTestSequence();
                },
                child: const Text('I can not hear it!'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}