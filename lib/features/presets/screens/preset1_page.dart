import 'package:flutter/material.dart';
import 'dart:io'; // For File I/O
import 'dart:convert'; // For JSON decoding/encoding
import 'package:path_provider/path_provider.dart'; // For app document directory

class Preset1Page extends StatefulWidget {
  final Map<String, dynamic> presetData;

  const Preset1Page({super.key, required this.presetData});

  @override
  _Preset1PageState createState() => _Preset1PageState();
}

class _Preset1PageState extends State<Preset1Page> {
  double dbValueOV = 0.0;
  double dbValueSB_BS = 0.0;
  double dbValueSB_MRS = 0.0;
  double dbValueSB_TS = 0.0;

  bool reduceBackgroundNoise = false;
  bool reduceWindNoise = false;
  bool softenSuddenNoise = false;

  // Load preset data
  Future<void> _loadPresetData() async {
    final presetData = widget.presetData['preset1']?['presetData']?[0];
    if (presetData != null) {
      setState(() {
        dbValueOV = presetData['db_valueOV'] ?? 0.0;
        dbValueSB_BS = presetData['db_valueSB_BS'] ?? 0.0;
        dbValueSB_MRS = presetData['db_valueSB_MRS'] ?? 0.0;
        dbValueSB_TS = presetData['db_valueSB_TS'] ?? 0.0;

        reduceBackgroundNoise = presetData['reduce_background_noise'] ?? false;
        reduceWindNoise = presetData['reduce_wind_noise'] ?? false;
        softenSuddenNoise = presetData['soften_sudden_noise'] ?? false;
      });
    }
  }

  // Save preset data
  Future<void> _savePresetData() async {
    widget.presetData['preset1'] = {
      'presetData': [
        {
          'db_valueOV': dbValueOV,
          'db_valueSB_BS': dbValueSB_BS,
          'db_valueSB_MRS': dbValueSB_MRS,
          'db_valueSB_TS': dbValueSB_TS,
          'reduce_background_noise': reduceBackgroundNoise,
          'reduce_wind_noise': reduceWindNoise,
          'soften_sudden_noise': softenSuddenNoise,
        },
      ]
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/preset_1_prototype.json');
    await file.writeAsString(jsonEncode(widget.presetData));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("'Preset 1' Successfully Saved!")),
    );
  }

  // Reset preset data
  void _resetPresetData() {
    setState(() {
      dbValueOV = 0.0;
      dbValueSB_BS = 0.0;
      dbValueSB_MRS = 0.0;
      dbValueSB_TS = 0.0;

      reduceBackgroundNoise = false;
      reduceWindNoise = false;
      softenSuddenNoise = false;
    });

    _savePresetData();
  }

  @override
  void initState() {
    super.initState();
    _loadPresetData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Preset 1',
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSlider(
                title: 'Overall Volume',
                value: dbValueOV,
                onChanged: (value) {
                  setState(() {
                    dbValueOV = value;
                  });
                },
              ),
              _buildSlider(
                title: 'Bass Sounds',
                value: dbValueSB_BS,
                onChanged: (value) {
                  setState(() {
                    dbValueSB_BS = value;
                  });
                },
              ),
              _buildSlider(
                title: 'Mid-Range Sounds',
                value: dbValueSB_MRS,
                onChanged: (value) {
                  setState(() {
                    dbValueSB_MRS = value;
                  });
                },
              ),
              _buildSlider(
                title: 'Treble Sounds',
                value: dbValueSB_TS,
                onChanged: (value) {
                  setState(() {
                    dbValueSB_TS = value;
                  });
                },
              ),
              _buildSwitch(
                title: 'Reduce Background Noise',
                value: reduceBackgroundNoise,
                onChanged: (value) {
                  setState(() {
                    reduceBackgroundNoise = value;
                  });
                },
              ),
              _buildSwitch(
                title: 'Reduce Wind Noise',
                value: reduceWindNoise,
                onChanged: (value) {
                  setState(() {
                    reduceWindNoise = value;
                  });
                },
              ),
              _buildSwitch(
                title: 'Soften Sudden Sounds',
                value: softenSuddenNoise,
                onChanged: (value) {
                  setState(() {
                    softenSuddenNoise = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _savePresetData,
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: _resetPresetData,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          min: -90.0,
          max: 90.0,
          divisions: 18,
          label: '${value.toStringAsFixed(1)} dB',
        ),
        Text('${value.toStringAsFixed(1)} dB'),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
