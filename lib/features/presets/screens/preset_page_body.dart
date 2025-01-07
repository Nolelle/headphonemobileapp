import 'package:flutter/material.dart';

class PresetPageBody extends StatelessWidget {
  final double dbValueOV;
  final double dbValueSB_BS;
  final double dbValueSB_MRS;
  final double dbValueSB_TS;
  final bool reduceBackgroundNoise;
  final bool reduceWindNoise;
  final bool softenSuddenNoise;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const PresetPageBody({
    super.key,
    required this.dbValueOV,
    required this.dbValueSB_BS,
    required this.dbValueSB_MRS,
    required this.dbValueSB_TS,
    required this.reduceBackgroundNoise,
    required this.reduceWindNoise,
    required this.softenSuddenNoise,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSliderSection(
              title: 'Overall Volume',
              value: dbValueOV,
              label: '${dbValueOV.toStringAsFixed(1)} dB',
            ),
            _buildSliderSection(
              title: 'Bass Sounds',
              value: dbValueSB_BS,
              label: '${dbValueSB_BS.toStringAsFixed(1)} dB',
            ),
            _buildSliderSection(
              title: 'Mid-Range Sounds',
              value: dbValueSB_MRS,
              label: '${dbValueSB_MRS.toStringAsFixed(1)} dB',
            ),
            _buildSliderSection(
              title: 'Treble Sounds',
              value: dbValueSB_TS,
              label: '${dbValueSB_TS.toStringAsFixed(1)} dB',
            ),
            _buildToggleSection(
              title: 'Reduce Background Noise',
              subtitle: 'Minimize constant background sounds',
              value: reduceBackgroundNoise,
            ),
            _buildToggleSection(
              title: 'Reduce Wind Noise',
              subtitle: 'Helps in outdoor environments',
              value: reduceWindNoise,
            ),
            _buildToggleSection(
              title: 'Soften Sudden Sounds',
              subtitle: 'Reduces unexpected loud noises',
              value: softenSuddenNoise,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  label: 'Save',
                  icon: Icons.save_rounded,
                  onPressed: onSave,
                ),
                _buildActionButton(
                  label: 'Reset',
                  icon: Icons.delete_forever,
                  onPressed: onReset,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.volume_up, size: 30),
            Text(
              ' $title',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: (_) {},
          min: -90.0,
          max: 90.0,
          divisions: 18,
          label: label,
        ),
        Align(
          alignment: Alignment.center,
          child: Text(label),
        ),
      ],
    );
  }

  Widget _buildToggleSection({
    required String title,
    required String subtitle,
    required bool value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
