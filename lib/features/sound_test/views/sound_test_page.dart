import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundTestPage extends StatefulWidget {
  const SoundTestPage({super.key});

  @override
  State<SoundTestPage> createState() => _SoundTestPageState();
}

class _SoundTestPageState extends State<SoundTestPage> {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound({double balance = 0.0}) async {
    String audioPath = "audio/eminem.mp3";
    await _player.setBalance(balance); // -1.0 = left ear and 1.0 = right ear
    await _player.play(AssetSource(audioPath));
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
              onPressed: () {
                playSound();
              },
              child: const Text("Play Me!"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => playSound(balance: -1.0),
              child: const Text("Play me in the left ear")
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => playSound(balance: 1.0),
                child: const Text("Play me in the right ear")
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: stopSound,
              child: const Text("RELEASE ME!"),
            )
          ],
        ),
      ),
    );
  }
}
