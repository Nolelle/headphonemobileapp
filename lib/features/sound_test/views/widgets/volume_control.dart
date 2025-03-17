import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VolumeControl extends StatefulWidget {
  final AudioPlayer player;
  final double initialVolume;
  final Function(double) onVolumeChanged;
  final Duration incrementDuration;

  const VolumeControl({
    super.key,
    required this.player,
    required this.initialVolume,
    required this.onVolumeChanged,
    this.incrementDuration = const Duration(milliseconds: 500),
  });

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  late double _currentVolume;

  @override
  void initState() {
    super.initState();
    _currentVolume = widget.initialVolume;
    widget.player.setVolume(_currentVolume);
  }

  Future<void> _incrementVolume() async {
    if (_currentVolume >= 1.0) return;

    final double targetVolume = (_currentVolume + 0.1).clamp(0.0, 1.0);
    final double startVolume = _currentVolume;
    final double volumeChange = targetVolume - startVolume;

    const int steps = 10;
    final double stepDuration = widget.incrementDuration.inMilliseconds / steps;
    final double volumeStep = volumeChange / steps;

    for (int i = 0; i < steps; i++) {
      _currentVolume = startVolume + (volumeStep * (i + 1));
      await widget.player.setVolume(_currentVolume);
      widget.onVolumeChanged(_currentVolume);
      setState(() {});

      await Future.delayed(Duration(milliseconds: stepDuration.round()));
    }
  }

  Future<void> _decrementVolume() async {
    if (_currentVolume <= 0.0) return;

    final double targetVolume = (_currentVolume - 0.1).clamp(0.0, 1.0);
    final double startVolume = _currentVolume;
    final double volumeChange = targetVolume - startVolume;

    const int steps = 10;
    final double stepDuration = widget.incrementDuration.inMilliseconds / steps;
    final double volumeStep = volumeChange / steps;

    for (int i = 0; i < steps; i++) {
      _currentVolume = startVolume + (volumeStep * (i + 1));
      await widget.player.setVolume(_currentVolume);
      widget.onVolumeChanged(_currentVolume);
      setState(() {});

      await Future.delayed(Duration(milliseconds: stepDuration.round()));
    }
  }

  void _onSliderChanged(double value) {
    setState(() {
      _currentVolume = value;
    });
    widget.player.setVolume(value);
    widget.onVolumeChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _decrementVolume,
        ),
        Expanded(
          child: Slider(
            value: _currentVolume,
            min: 0.0,
            max: 1.0,
            onChanged: _onSliderChanged,
          ),
        ),
        Icon(
          _currentVolume > 0.5 ? Icons.volume_up : Icons.volume_down,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _incrementVolume,
        ),
      ],
    );
  }
}
