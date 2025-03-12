import 'package:flutter/material.dart';
import '../../providers/preset_provider.dart';
import '../../models/preset.dart';

class PresetPage extends StatefulWidget {
  final String presetId;
  final String presetName;
  final PresetProvider presetProvider;

  const PresetPage({
    super.key,
    required this.presetId,
    required this.presetName,
    required this.presetProvider,
  });

  @override
  _PresetPageState createState() => _PresetPageState();
}

class _PresetPageState extends State<PresetPage> {
  // Preset values
  late TextEditingController _nameController;
  double db_valueOV = 0.0;
  double db_valueSB_BS = 0.0;
  double db_valueSB_MRS = 0.0;
  double db_valueSB_TS = 0.0;
  bool reduce_background_noise = false;
  bool reduce_wind_noise = false;
  bool soften_sudden_noise = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.presetName);
    _loadPresetData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadPresetData() {
    final preset = widget.presetProvider.presets[widget.presetId];
    if (preset != null) {
      final data = preset.presetData;
      setState(() {
        db_valueOV = data['db_valueOV'] ?? 0.0;
        db_valueSB_BS = data['db_valueSB_BS'] ?? 0.0;
        db_valueSB_MRS = data['db_valueSB_MRS'] ?? 0.0;
        db_valueSB_TS = data['db_valueSB_TS'] ?? 0.0;
        reduce_background_noise = data['reduce_background_noise'] ?? false;
        reduce_wind_noise = data['reduce_wind_noise'] ?? false;
        soften_sudden_noise = data['soften_sudden_noise'] ?? false;
      });
    }
  }

  Future<void> _savePreset() async {
    final preset = Preset(
      id: widget.presetId,
      name: _nameController.text,
      dateCreated: DateTime.now(),
      presetData: {
        'db_valueOV': db_valueOV,
        'db_valueSB_BS': db_valueSB_BS,
        'db_valueSB_MRS': db_valueSB_MRS,
        'db_valueSB_TS': db_valueSB_TS,
        'reduce_background_noise': reduce_background_noise,
        'reduce_wind_noise': reduce_wind_noise,
        'soften_sudden_noise': soften_sudden_noise,
      },
    );

    await widget.presetProvider.updatePreset(preset);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} Successfully Updated!'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper method to auto-save after each change
  void _autoSave() {
    // Use a debounce to avoid too many saves
    Future.microtask(() => _savePreset());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        title: const Text(
          'Edit Preset',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Save before navigating back
            _savePreset().then((_) {
              Navigator.of(context).pop();
            });
          },
        ),
      ),
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPresetNameSection(),
              _buildOverallVolumeSection(),
              _buildSoundBalanceSection(),
              _buildSoundEnhancementSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetNameSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preset Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
            ),
            style: const TextStyle(fontSize: 18.0),
            onChanged: (_) {
              _autoSave();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverallVolumeSection() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.volume_up,
              color: Colors.black,
              size: 30,
            ),
            Text(
              ' Overall Volume',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Softer'),
              Text('Louder'),
            ],
          ),
          Slider(
            value: db_valueOV,
            onChanged: (value) {
              setState(() => db_valueOV = value);
              _autoSave();
            },
            min: -10.0,
            max: 10.0,
            divisions: 18,
            label: '${db_valueOV.toStringAsFixed(1)} dB',
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '${db_valueOV.toStringAsFixed(1)} dB',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundBalanceSection() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.earbuds_rounded,
              color: Colors.black,
              size: 30,
            ),
            Text(
              ' Sound Balance',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),

          // Bass Sounds slider
          Container(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Bass',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Softer'),
                    Text('Louder'),
                  ],
                ),
                Slider(
                  value: db_valueSB_BS,
                  onChanged: (value) {
                    setState(() => db_valueSB_BS = value);
                    _autoSave();
                  },
                  min: -10.0,
                  max: 10.0,
                  divisions: 18,
                  label: '${db_valueSB_BS.toStringAsFixed(1)} dB',
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${db_valueSB_BS.toStringAsFixed(1)} dB',
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances low frequencies like bass drums and deep voices',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Mid Range Sounds slider
          Container(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Mid',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Softer'),
                    Text('Louder'),
                  ],
                ),
                Slider(
                  value: db_valueSB_MRS,
                  onChanged: (value) {
                    setState(() => db_valueSB_MRS = value);
                    _autoSave();
                  },
                  min: -10.0,
                  max: 10.0,
                  divisions: 18,
                  label: '${db_valueSB_MRS.toStringAsFixed(1)} dB',
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${db_valueSB_MRS.toStringAsFixed(1)} dB',
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances vocals and most speech frequencies',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Treble Sounds slider
          Container(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Treble',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Softer'),
                    Text('Louder'),
                  ],
                ),
                Slider(
                  value: db_valueSB_TS,
                  onChanged: (value) {
                    setState(() => db_valueSB_TS = value);
                    _autoSave();
                  },
                  min: -10.0,
                  max: 10.0,
                  divisions: 18,
                  label: '${db_valueSB_TS.toStringAsFixed(1)} dB',
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${db_valueSB_TS.toStringAsFixed(1)} dB',
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances high frequencies like cymbals and consonant sounds',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundEnhancementSection() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.add_sharp,
              color: Colors.black,
              size: 30,
            ),
            Text(
              ' Sound Enhancement',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),

          // Reduce Background Noise toggle
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reduce Background Noise',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Minimize constant background sounds',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reduce_background_noise,
                onChanged: (value) {
                  setState(() => reduce_background_noise = value);
                  _autoSave();
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                inactiveTrackColor: Colors.grey,
              ),
            ],
          ),

          // Reduce Wind Noise toggle
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reduce Wind Noise',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Helps in outdoor environments',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reduce_wind_noise,
                onChanged: (value) {
                  setState(() => reduce_wind_noise = value);
                  _autoSave();
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                inactiveTrackColor: Colors.grey,
              ),
            ],
          ),

          // Soften Sudden Sounds toggle
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Soften Sudden Sounds',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Reduces unexpected loud noises',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: soften_sudden_noise,
                onChanged: (value) {
                  setState(() => soften_sudden_noise = value);
                  _autoSave();
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                inactiveTrackColor: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
