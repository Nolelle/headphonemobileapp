import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../bluetooth/providers/bluetooth_provider.dart';
import '../../../bluetooth/platform/bluetooth_platform.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
      // Verify audio connection first
      bool audioConnected = await bluetoothProvider.verifyAudioConnection();

      if (bluetoothProvider.isDeviceConnected && !audioConnected) {
        // If our app thinks it's connected but audio isn't working, try to force it
        await BluetoothPlatform.forceAudioRoutingToBluetooth();
        audioConnected = await bluetoothProvider.verifyAudioConnection();
      }

      String audioPath = "audio/eminem.mp3";
      await player.setVolume(volume);

      // Log the connection status
      print(
          "Playing audio. Bluetooth connected: ${bluetoothProvider.isDeviceConnected}");
      print("Audio connected: $audioConnected");
      print("Connected device: ${bluetoothProvider.connectedDeviceName}");

      // Play the audio
      await player.play(AssetSource(audioPath));

      setState(() {
        isPlaying = true;
      });

      // Show a message about where audio is playing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            audioConnected
                ? 'Playing through ${bluetoothProvider.connectedDeviceName}'
                : 'Playing through device speaker (Bluetooth not connected for audio)',
          ),
          duration: const Duration(seconds: 3),
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bluetooth Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bluetooth Connection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${provider.isBluetoothEnabled ? 'Enabled' : 'Disabled'}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connected: ${provider.isDeviceConnected ? 'Yes' : 'No'}',
                      ),
                      const SizedBox(height: 4),
                      Text('Device: ${provider.connectedDeviceName}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            _openBluetoothSettings(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(133, 86, 169, 1.00),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Open Bluetooth Settings'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Audio Test Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Audio Test',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: playSound,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(133, 86, 169, 1.00),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isPlaying ? 'Stop' : 'Play Test Sound'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Volume'),
                                Slider(
                                  value: volume,
                                  onChanged: updateVolume,
                                  activeColor:
                                      const Color.fromRGBO(133, 86, 169, 1.00),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Developer Options
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Developer Options',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Advanced options for developers are available on the Bluetooth connection screen.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // App Info
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Version: 1.0.0'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBluetoothSettings(
      BuildContext context, BluetoothProvider provider) async {
    await provider.connectViaSystemSettings();
  }
}
