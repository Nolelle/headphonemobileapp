import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import './preset_page.dart';
import '../../providers/preset_provider.dart';
import '../../../bluetooth/providers/bluetooth_provider.dart';
import '../../models/preset.dart';

class PresetsListPage extends StatefulWidget {
  final PresetProvider presetProvider;

  const PresetsListPage({
    super.key,
    required this.presetProvider,
  });

  @override
  State<PresetsListPage> createState() => _PresetsListPageState();
}

class _PresetsListPageState extends State<PresetsListPage> {
  String? activePresetId; // Tracks the currently active preset ID
  final player = AudioPlayer();
  double volume = 1.0;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Set up audio session for proper routing
    _setupAudioSession();

    // Listen for playback completion
    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _setupAudioSession() async {
    // This ensures the audio session is properly configured
    await player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playSound() async {
    // Check if already playing
    if (isPlaying) {
      await player.stop();
      setState(() {
        isPlaying = false;
      });
      return;
    }

    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);

    try {
      String audioPath = "audio/eminem.mp3";
      await player.setVolume(volume);

      // Log the connection status
      print(
          "Playing audio. Bluetooth connected: ${bluetoothProvider.isDeviceConnected}");
      print("Connected device: ${bluetoothProvider.connectedDeviceName}");

      // Play the audio - it will automatically route to the connected audio device
      await player.play(AssetSource(audioPath));

      setState(() {
        isPlaying = true;
      });

      // Show a message about where audio is playing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bluetoothProvider.isDeviceConnected
                ? 'Playing through ${bluetoothProvider.connectedDeviceName}'
                : 'Playing through device speaker',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error playing audio: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  void updateVolume(double value) {
    setState(() {
      volume = value;
    });
    player.setVolume(volume);
  }

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

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String presetName) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: Text('Are you sure you want to delete "$presetName"?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }
  // Future<bool> _showDeleteConfirmationDialog(
  //     BuildContext context, String presetName) async {
  //   return await showDialog<bool>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Confirm Delete'),
  //         content: Text('Are you sure you want to delete "$presetName"?'),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () => Navigator.of(context).pop(false),
  //           ),
  //           TextButton(
  //             child: const Text('Delete'),
  //             onPressed: () => Navigator.of(context).pop(true),
  //           ),
  //         ],
  //       );
  //     },
  //   ) ??
  //       false;

  // }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PresetProvider>(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final shouldActivate =
                                  await _showConfirmationDialog(
                                      context, preset.name);

                              if (shouldActivate) {
                                setState(() {
                                  activePresetId = preset
                                      .id; // Show dropdown for this preset
                                });

                                provider.setActivePreset(preset.id);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${preset.name} Successfully Sent To Device!'),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      preset.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Show dropdown only if this preset is active
                          if (activePresetId == preset.id)
                            DropdownButton<String>(
                              value: null, // No initial value for the dropdown
                              hint: const Text('What does thou want to do :3'),
                              onChanged: (String? value) async {
                                if (value == null) return;

                                switch (value) {
                                  case 'edit':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PresetPage(
                                          presetId: preset.id,
                                          presetName: preset.name,
                                          presetProvider: widget.presetProvider,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 'delete':
                                    final shouldDelete =
                                        await _showDeleteConfirmationDialog(
                                            context, preset.name);
                                    if (shouldDelete) {
                                      provider.deletePreset(preset.id);
                                      setState(() {
                                        activePresetId = null; // Hide dropdown
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${preset.name} deleted successfully!'),
                                        ),
                                      );
                                    }
                                    break;
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                DropdownMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          //temp
          //audio player for testing purposes
          Center(
            child: Column(children: [
              ElevatedButton.icon(
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(isPlaying ? 'Stop' : 'Play Test Sound'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlaying ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: playSound,
              ),
              const SizedBox(height: 10),
              // Volume Control Slider
              Column(
                children: [
                  const Text('Volume',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: (volume * 100).toStringAsFixed(0),
                    onChanged: updateVolume,
                  ),
                ],
              ),
            ]),
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
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        onPressed: () async {
          final presetCount = widget.presetProvider.presets.length;
          if (presetCount >= 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You can only have a maximum of 10 presets!'),
              ),
            );
            return;
          }

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

          await widget.presetProvider.createPreset(newPreset);

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PresetPage(
                  presetId: newId,
                  presetName: 'New Preset',
                  presetProvider: widget.presetProvider,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Future<bool> _showConfirmationDialog(
  //     BuildContext context, String presetName) async {
  //   return await showDialog<bool>(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text('Confirm Preset Activation'),
  //             content:
  //                 Text('Do you want to send "$presetName" to your device?'),
  //             actions: <Widget>[
  //               TextButton(
  //                 child: const Text('Cancel'),
  //                 onPressed: () => Navigator.of(context).pop(false),
  //               ),
  //               TextButton(
  //                 child: const Text('Send'),
  //                 onPressed: () => Navigator.of(context).pop(true),
  //               ),
  //             ],
  //           );
  //         },
  //       ) ??
  //       false;
  // }
}
