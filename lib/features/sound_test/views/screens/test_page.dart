import 'dart:async';
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
  late IconData _iconController;
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
  double ear_balance = 0.0; //-1.0 for left, 0.0 for both, 1.0 for right
  int current_sound_stage = 0;

  Timer? tempTimer;
  late double current_volume = 0.0;
  final double MAX_VOLUME = 1.0;
  final int TIMER_DURATION = 10;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.soundTestName);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateFrequency_dB_Value() {
    double capturedVolume = current_volume;

    if (current_ear == "L") {
      switch (current_sound_stage) {
        case 1:
          debugPrint("Current volume for frequency: $capturedVolume");
          L_user_250Hz_dB = capturedVolume;
          break;
        case 2:
          debugPrint("$capturedVolume");
          L_user_500Hz_dB = capturedVolume;
          break;
        case 3:
          debugPrint("$capturedVolume");
          L_user_1000Hz_dB = capturedVolume;
          break;
        case 4:
          debugPrint("$capturedVolume");
          L_user_2000Hz_dB = capturedVolume;
          break;
        case 5:
          debugPrint("$capturedVolume");
          L_user_4000Hz_dB = capturedVolume;
          break;
        case 6:
          debugPrint("$capturedVolume");
          L_user_8000Hz_dB = capturedVolume;
          break;
      }
    } else if (current_ear == "R") {
      switch (current_sound_stage) {
        case 1:
          debugPrint("$capturedVolume");
          R_user_250Hz_dB = capturedVolume;
          break;
        case 2:
          debugPrint("$capturedVolume");
          R_user_500Hz_dB = capturedVolume;
          break;
        case 3:
          debugPrint("$capturedVolume");
          R_user_1000Hz_dB = capturedVolume;
          break;
        case 4:
          debugPrint("$capturedVolume");
          R_user_2000Hz_dB = capturedVolume;
          break;
        case 5:
          debugPrint("$capturedVolume");
          R_user_4000Hz_dB = capturedVolume;
          break;
        case 6:
          debugPrint("$capturedVolume");
          R_user_8000Hz_dB = capturedVolume;
          break;
      }
    }
  }

  void updateCurrentEar() {
    setState(() {
      if (current_ear == "") {
        current_ear = "L";
        ear_balance = -1.0;
      } else if (current_ear == "L" && current_sound_stage == 6) {
        current_ear = "R";
        ear_balance = 1.0;
        current_sound_stage = 0;
      } else if (current_ear == "R" && current_sound_stage == 6) {
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
                _showProfileCreationDialog(
                    context); // Show the profile creation dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileCreationDialog(BuildContext context) {
    IconData selectedIcon = Icons.home; // Default icon
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
                      _saveSoundTest(Icons.home);
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
                            _saveSoundTest(selectedIcon);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.music_note),
                        onPressed: () {
                          setState(() {
                            selectedIcon = Icons.music_note;
                            _saveSoundTest(selectedIcon);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.hearing),
                        onPressed: () {
                          setState(() {
                            selectedIcon = Icons.hearing;
                            _saveSoundTest(selectedIcon);
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

                    // Navigator.of(context, rootNavigator: true).pop(); // Close the profile creation dialog
                    // Navigator.of(context, rootNavigator: true).pop(); // Close the test completion dialog
                    Navigator.of(context).popUntil(
                        (route) => route.isFirst); // Go back to the first route
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
      name: _nameController.text,
      dateCreated: DateTime.now(),
      soundTestData: {
        'L_user_250Hz_dB': L_user_250Hz_dB,
        'L_user_500Hz_dB': L_user_500Hz_dB,
        'L_user_1000Hz_dB': L_user_1000Hz_dB,
        'L_user_2000Hz_dB': L_user_2000Hz_dB,
        'L_user_4000Hz_dB': L_user_4000Hz_dB,
        'L_user_8000Hz_dB': L_user_8000Hz_dB,
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

  Color determineCurrentSoundStageBGColor(int soundStage) {
    if (soundStage == current_sound_stage) {
      return const Color.fromRGBO(255, 255, 255, 1.0);
    }
    return const Color.fromRGBO(133, 86, 169, 1.0);
  }

  Color determineCurrentSoundStageTextColor(int soundStage) {
    if (soundStage == current_sound_stage) {
      return Colors.black54;
    }
    return Colors.white;
  }

  //TODO
  final AudioPlayer temp_player = AudioPlayer();
  final String _250Hz_audio = "audio/250Hz.wav";
  final String _500Hz_audio = "audio/500Hz.wav";
  final String _1000Hz_audio = "audio/1000Hz.wav";
  final String _2000Hz_audio = "audio/2000Hz.wav";
  final String _4000Hz_audio = "audio/4000Hz.wav";
  final String _8000Hz_audio = "audio/8000Hz.wav";

  Future<void> tempPlaySound(double balance) async {
    await temp_player.stop();
    updateCurrentEar();

    current_sound_stage++;
    String currentFrequency = "";

    if (current_sound_stage <= 1) {
      currentFrequency = _250Hz_audio;
    } else if (current_sound_stage == 2) {
      currentFrequency = _500Hz_audio;
    } else if (current_sound_stage == 3) {
      currentFrequency = _1000Hz_audio;
    } else if (current_sound_stage == 4) {
      currentFrequency = _2000Hz_audio;
    } else if (current_sound_stage == 5) {
      currentFrequency = _4000Hz_audio;
    } else if (current_sound_stage == 6) {
      currentFrequency = _8000Hz_audio;
    }
    await temp_player.play(
      AssetSource(currentFrequency),
      volume: current_volume,
      balance: ear_balance,
    );
  }

  Future<void> tempIncrementVolume(
      AudioPlayer player, double durationInSeconds) async {
    const int steps = 100;
    final double stepDuration = durationInSeconds / steps;
    const double volumeIncrement = 0.125 / steps;

    //we need to reset it every time we run this method
    current_volume = 0.0;
    await player.setVolume(current_volume);

    for (int i = 0; i < steps; i++) {
      await Future.delayed(
          Duration(milliseconds: (stepDuration * 1000).round()));
      current_volume += volumeIncrement;
      await player.setVolume(current_volume);
    }
  }

  void tempHandleHearingTestSequence() {
    //this is the order i think it needs to be in:
    // - press button
    // - find and save the volume of the frequency
    // - change to the next stage
    //   - play the sound on the correct ear
    //   - increment the volume
    // - rince and repeat until stage 6
    // - switch ears
    //   - play the sound on the correct ear
    //   - increment the volume
    // - rinse and repeat until stage 6
    // - show completetion
    updateCurrentEar();
    updateFrequency_dB_Value();
    tempPlaySound(ear_balance);
    tempIncrementVolume(temp_player, 10.0);

    if (current_ear == "R" && current_sound_stage == 6) {
      temp_player.stop();
      temp_player.dispose();
    }
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
                  content:
                      const Text("Are you sure you want to cancel the test?"),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(), // Close dialog
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context)
                            .pop(); // Go back to the previous screen
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
                    style: TextStyle(fontSize: 20),
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
              ],
            )
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
                      fontWeight: FontWeight.bold),
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
                      fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ));
  }

  Widget _buildFrequencyStageSelection(BuildContext context) {
    return Column(children: [
      Padding(
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
            Container(
              height: 35,
              width: 35,
              alignment: Alignment.center, // Centers text
              decoration: BoxDecoration(
                color: determineCurrentSoundStageBGColor(6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "6",
                style: TextStyle(
                  color: determineCurrentSoundStageTextColor(6),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(50),
        child: ElevatedButton(
            onPressed: tempHandleHearingTestSequence,
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.75, horizontal: 25),
            ),
            child: const Text(
              "I can hear it!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            )),
      )
    ]);
  }
}
