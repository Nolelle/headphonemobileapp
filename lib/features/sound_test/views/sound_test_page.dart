import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundTestPage extends StatefulWidget {
  const SoundTestPage({super.key});

  @override
  State<SoundTestPage> createState() => _SoundTestPageState();
}

class _SoundTestPageState extends State<SoundTestPage> {
  final AudioPlayer _player = AudioPlayer();
  double _volume = 1.0;
  double _balance = 0.0;

  Future<void> playSound() async {
    await _player.setVolume(_volume);
    await _player.setBalance(_balance);
    await _player.play(AssetSource("audio/soundTest.mp3"));
  }

  Future<void> stopSound() async {
    await _player.stop();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Play Me!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: playSound,
              child: const Text("Play Me!"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: stopSound,
              child: const Text("RELEASE ME!"),
            ),
            const SizedBox(height: 40),
            Column(
              children: [
                const Text("Volume"),
                Slider(
                  value: _volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _volume = value;
                      _player.setVolume(_volume);
                    });
                  },
                ),
                const Text("Balance"),
                Slider(
                  value: _balance,
                  min: -1.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _balance = value;
                      _player.setBalance(_balance);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
