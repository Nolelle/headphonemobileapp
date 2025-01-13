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
          content: Text('${_nameController.text} Successfully Saved!'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preset Name Section moved to top
              _buildPresetNameSection(),

              // Overall Volume Section
              _buildOverallVolumeSection(),

              // Sound Balance Section
              _buildSoundBalanceSection(),

              // Sound Enhancement Section
              _buildSoundEnhancementSection(),

              // Buttons Section
              _buildButtonsSection(),
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
            onChanged: (value) => setState(() => db_valueOV = value),
            min: -90.0,
            max: 90.0,
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
          // Sound Balance header
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bass Sounds'),
                    Text('Louder'),
                  ],
                ),
                Slider(
                  value: db_valueSB_BS,
                  onChanged: (value) => setState(() => db_valueSB_BS = value),
                  min: -90.0,
                  max: 90.0,
                  divisions: 18,
                  label: '${db_valueSB_BS.toStringAsFixed(1)} dB',
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances deep sounds like background noise and speech fundamentals\n',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),

          // Mid-Range Sounds slider
          Container(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mid-Range Sounds'),
                    Text('Louder'),
                  ],
                ),
                Slider(
                  value: db_valueSB_MRS,
                  onChanged: (value) => setState(() => db_valueSB_MRS = value),
                  min: -90.0,
                  max: 90.0,
                  divisions: 18,
                  label: '${db_valueSB_MRS.toStringAsFixed(1)} dB',
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances main speech sounds and voices\n',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),

          // Treble Sounds slider
          Container(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Treble Sounds'),
                    Text('Louder'),
                  ],
                ),
                Slider(
                  value: db_valueSB_TS,
                  onChanged: (value) => setState(() => db_valueSB_TS = value),
                  min: -90.0,
                  max: 90.0,
                  divisions: 18,
                  label: '${db_valueSB_TS.toStringAsFixed(1)} dB',
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances clarity and crisp sounds like consonants\n',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
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
          // Sound Enhancement header
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
                onChanged: (value) =>
                    setState(() => reduce_background_noise = value),
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
                onChanged: (value) => setState(() => reduce_wind_noise = value),
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
                onChanged: (value) =>
                    setState(() => soften_sudden_noise = value),
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

  Widget _buildButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Save button
          ElevatedButton(
              onPressed: _savePreset,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded),
                  Text(
                    " Save",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )),

          // Delete button
          ElevatedButton(
              onPressed: () async {
                await widget.presetProvider.deletePreset(widget.presetId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${widget.presetName} Successfully Deleted!'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever),
                  Text(
                    " Delete",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
