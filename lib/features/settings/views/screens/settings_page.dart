// lib/features/settings/views/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../../../bluetooth/providers/bluetooth_provider.dart';
import '../../../bluetooth/views/screens/bluetooth_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    try {
      // Set volume
      await _audioPlayer.setVolume(_volume);

      // Play Eminem track
      await _audioPlayer.play(AssetSource('audio/eminem.mp3'));

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print('Error playing sound: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing sound: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

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
              // Bluetooth connection status
              Card(
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
                      Row(
                        children: [
                          Icon(
                            bluetoothProvider.isDeviceConnected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_disabled,
                            color: bluetoothProvider.isDeviceConnected
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            bluetoothProvider.isDeviceConnected
                                ? 'Connected to: ${bluetoothProvider.connectedDeviceName}'
                                : 'No device connected',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Audio Test Section
              Card(
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
                      const Text(
                        'Use this tool to verify audio is properly routing to your connected headphones.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // Volume slider
                      Row(
                        children: [
                          const Icon(Icons.volume_down),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              onChanged: (value) {
                                setState(() {
                                  _volume = value;
                                  _audioPlayer.setVolume(_volume);
                                });
                              },
                              min: 0.0,
                              max: 1.0,
                            ),
                          ),
                          const Icon(Icons.volume_up),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Play button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _playSound,
                          icon:
                              Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                          label: Text(_isPlaying ? 'Stop' : 'Play Eminem.mp3'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(133, 86, 169, 1.00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Force audio routing button
                      if (bluetoothProvider.isDeviceConnected)
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              try {
                                await bluetoothProvider.forceAudioRouting();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Forced audio routing to Bluetooth device'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.bluetooth_audio),
                            label: const Text('Force Audio Routing'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bluetooth settings button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BluetoothSettingsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_bluetooth),
                label: const Text('Bluetooth Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
