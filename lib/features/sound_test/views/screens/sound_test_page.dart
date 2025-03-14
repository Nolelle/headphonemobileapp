import 'package:flutter/material.dart';
import 'package:projects/features/sound_test/views/screens/test_page.dart';
import 'package:provider/provider.dart';
import '../../providers/sound_test_provider.dart';
import '../../models/sound_test.dart';

class SoundTestPage extends StatefulWidget {
  final SoundTestProvider soundTestProvider;

  const SoundTestPage({
    super.key,
    required this.soundTestProvider,
  });

  @override
  State<SoundTestPage> createState() => _SoundTestPageState();
}

class _SoundTestPageState extends State<SoundTestPage> {
  String? activeSoundTestId; // Track the current active audio profile ID

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String soundTestName) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content:
                  Text('Are you sure you want to delete "$soundTestName"?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => _deleteAudioProfile(),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _deleteAudioProfile() {
    // Close the dialog
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color iconColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sound Test'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            //this is the intructions, might have this as a "if theres no audio profiles, then show" type thing
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      final audioProfileCount =
                          widget.soundTestProvider.soundTests.length;
                      if (audioProfileCount >= 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'You can only have a maximum of 3 audio profiles!'),
                          ),
                        );
                        return;
                      }

                      final newId =
                          'soundTest_${DateTime.now().millisecondsSinceEpoch}';
                      final newSounTest = SoundTest(
                        id: newId,
                        name: 'Audio Profile #${audioProfileCount + 1}',
                        dateCreated: DateTime.now(),
                        soundTestData: {
                          'L_user_250Hz_dB': 0.0,
                          'L_user_500Hz_dB': 0.0,
                          'L_user_1000Hz_dB': 0.0,
                          'L_user_2000Hz_dB': 0.0,
                          'L_user_4000Hz_dB': 0.0,
                          'L_user_8000Hz_dB': 0.0,
                          'R_user_250Hz_dB': 0.0,
                          'R_user_500Hz_dB': 0.0,
                          'R_user_1000Hz_dB': 0.0,
                          'R_user_2000Hz_dB': 0.0,
                          'R_user_4000Hz_dB': 0.0,
                          'R_user_8000Hz_dB': 0.0,
                        },
                        icon: Icons.music_note,
                      );

                      await widget.soundTestProvider
                          .createSoundTest(newSounTest);

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestPage(
                              soundTestId: newId,
                              soundTestName:
                                  'Audio Profile #${audioProfileCount + 1}',
                              soundTestProvider: widget.soundTestProvider,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Begin Sound Test'),
                  ),
                ),
                Text(
                  'Some instructions before starting the test:',
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                ListBody(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.keyboard_arrow_right,
                        color: iconColor,
                      ),
                      title: Text(
                        'Sit in a quiet environment.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.keyboard_arrow_right,
                        color: iconColor,
                      ),
                      title: Text(
                        'Wear your headphones correctly and comfortably.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.keyboard_arrow_right,
                        color: iconColor,
                      ),
                      title: Text(
                        'Press the button when you hear the sound.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //title of 'Audio Presets' with counter
          Consumer<SoundTestProvider>(builder: (context, provider, child) {
            final audioProfileCount = provider.soundTests.length;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Audio Profiles: $audioProfileCount/3',
                style: TextStyle(
                  fontSize: 18,
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
          //the audio profiles
          Expanded(
            child: Consumer<SoundTestProvider>(
              builder: (context, provider, child) {
                final soundTests = provider.soundTests.values.toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: soundTests.length,
                  itemBuilder: (context, index) {
                    final soundTest = soundTests[index];
                    final isActive = soundTest.id == provider.activeSoundTestId;

                    return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    activeSoundTestId = soundTest.id;
                                  });

                                  provider.setActiveSoundTest(soundTest.id);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${soundTest.name} Successfully Applied!'),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? theme.colorScheme.secondary
                                      : theme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 10, 0),
                                                child: Icon(
                                                  soundTest.icon,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                              ),
                                              Text(
                                                soundTest.name,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ]),
                                        IconButton(
                                          onPressed: () async {
                                            final shouldDelete =
                                                await _showDeleteConfirmationDialog(
                                                    context, soundTest.name);
                                            if (shouldDelete) {
                                              provider.deleteSoundTest(
                                                  soundTest.id);
                                              setState(() {
                                                activeSoundTestId = null;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${soundTest.name} deleted successfully!'),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.delete_forever,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
