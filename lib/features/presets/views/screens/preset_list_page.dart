import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import './preset_page.dart';
import '../../providers/preset_provider.dart';
import '../../models/preset.dart';

class PresetsListPage extends StatelessWidget {
  final PresetProvider presetProvider;

  const PresetsListPage({
    super.key,
    required this.presetProvider,
  });

<<<<<<< Updated upstream
=======
  @override
  State<PresetsListPage> createState() => _PresetsListPageState();
}

class _PresetsListPageState extends State<PresetsListPage> {
  String? activePresetId; // Tracks the currently active preset ID
  final player = AudioPlayer();
<<<<<<< Updated upstream
=======

  Future<void> playSound() async {
    String audioPath = "audio/eminem.mp3";
    await player.play(AssetSource(audioPath));
  }
>>>>>>> Stashed changes

  Future<void> playSound() async {
    String audioPath = "audio/eminem.mp3";
    await player.play(AssetSource(audioPath)  );
  }

>>>>>>> Stashed changes
  Future<bool> _showConfirmationDialog(
      BuildContext context, String presetName) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Preset Activation'),
              content:
                  Text('Do you want to send "$presetName" to your device?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Send'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: Consumer<PresetProvider>(
        builder: (context, provider, child) {
          final presets = provider.presets.values.toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              final isActive = preset.id == provider.activePresetId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final shouldActivate =
                        await _showConfirmationDialog(context, preset.name);

                    if (shouldActivate) {
                      provider.setActivePreset(preset.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '\'${preset.name}\' Successfully Sent To Device!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive
                        ? const Color.fromRGBO(93, 59, 129, 1.00)
                        : const Color.fromRGBO(133, 86, 169, 1.00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            preset.name,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PresetPage(
                                    presetId: preset.id,
                                    presetName: preset.name,
                                    presetProvider: provider,
                                  ),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
<<<<<<< Updated upstream
                    ),
=======
                    );
                  },
                );
              },
            ),
          ),
          //temp
          //audio player for testing purposes
          Center(
            child: ElevatedButton(
                onPressed: () {
                  playSound();
                },
                child: const Text("Play me!")
            )
          ),

          Consumer<PresetProvider>(
            builder: (context, provider, child) {
              final presetCount = provider.presets.length;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Presets: $presetCount/10',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
>>>>>>> Stashed changes
                  ),
                ),
              );
            },
<<<<<<< Updated upstream
          );
        },
=======
          ),

        ],
>>>>>>> Stashed changes
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        onPressed: () async {
          final newId = 'preset_${DateTime.now().millisecondsSinceEpoch}';
          final newPreset = Preset(
            id: newId,
            name: 'New Preset',
            dateCreated: DateTime.now(),
            presetData: {
              'db_valueOV': 0.0,
              'db_valueSB_BS': 0.0,
              'db_valueSB_MRS': 0.0,
              'db_valueSB_TS': 0.0,
              'reduce_background_noise': false,
              'reduce_wind_noise': false,
              'soften_sudden_noise': false,
            },
          );

          await presetProvider.createPreset(newPreset);

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PresetPage(
                  presetId: newId,
                  presetName: 'New Preset',
                  presetProvider: presetProvider,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
