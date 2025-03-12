import 'package:flutter/material.dart';
import 'dart:async'; // Add this import for Timer
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

  // Status tracking
  bool _isSaving = false;
  Timer? _debounceTimer;
  String? _lastSavedSetting;

  // SnackBar controller
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _currentSnackBar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.presetName);
    _loadPresetData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _debounceTimer?.cancel();
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

  Future<void> _savePreset({String? settingName}) async {
    // Update the last saved setting
    _lastSavedSetting = settingName;

    setState(() {
      _isSaving = true;
    });

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

    try {
      await widget.presetProvider.updatePreset(preset);

      if (mounted) {
        // Dismiss any existing SnackBar
        _currentSnackBar?.close();

        // Show a new SnackBar with the updated setting
        String message = '${_nameController.text} Successfully Updated!';
        if (settingName != null) {
          message = '$settingName updated';
        }

        _currentSnackBar = ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            action: _isSaving
                ? SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () {
                      _currentSnackBar?.close();
                    },
                  )
                : null,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Helper method to auto-save after each change with debouncing
  void _autoSave({String? settingName}) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Show saving indicator immediately
    if (mounted) {
      setState(() {
        _isSaving = true;
      });

      // Dismiss any existing SnackBar and show "Updating..." message
      _currentSnackBar?.close();
      _currentSnackBar = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(settingName != null
                  ? 'Updating $settingName...'
                  : 'Updating...'),
            ],
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        ),
      );
    }

    // Set a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _savePreset(settingName: settingName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
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
            // Cancel any pending auto-save
            _debounceTimer?.cancel();

            // Save before navigating back
            _savePreset().then((_) {
              Navigator.of(context).pop();
            });
          },
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPresetNameSection(textColor),
              _buildOverallVolumeSection(textColor, subtitleColor),
              _buildSoundBalanceSection(textColor, subtitleColor),
              _buildSoundEnhancementSection(textColor, subtitleColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetNameSection(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preset Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
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
            style: TextStyle(fontSize: 18.0, color: textColor),
            onChanged: (_) {
              _autoSave(settingName: 'Preset name');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverallVolumeSection(Color textColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.volume_up,
              color: textColor,
              size: 30,
            ),
            Text(
              ' Overall Volume',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Softer', style: TextStyle(color: textColor)),
              Text('Louder', style: TextStyle(color: textColor)),
            ],
          ),
          Slider(
            value: db_valueOV,
            onChanged: (value) {
              setState(() => db_valueOV = value);
              _autoSave(settingName: 'Overall Volume');
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
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundBalanceSection(Color textColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.earbuds_rounded,
              color: textColor,
              size: 30,
            ),
            Text(
              ' Sound Balance',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ]),

          // Bass Sounds slider
          Container(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Bass',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Softer', style: TextStyle(color: textColor)),
                    Text('Louder', style: TextStyle(color: textColor)),
                  ],
                ),
                Slider(
                  value: db_valueSB_BS,
                  onChanged: (value) {
                    setState(() => db_valueSB_BS = value);
                    _autoSave(settingName: 'Bass');
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
                    style: TextStyle(color: textColor),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances low frequencies like bass drums and deep voices',
                    style: TextStyle(fontSize: 12, color: subtitleColor),
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
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Mid',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Softer', style: TextStyle(color: textColor)),
                    Text('Louder', style: TextStyle(color: textColor)),
                  ],
                ),
                Slider(
                  value: db_valueSB_MRS,
                  onChanged: (value) {
                    setState(() => db_valueSB_MRS = value);
                    _autoSave(settingName: 'Mid');
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
                    style: TextStyle(color: textColor),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances vocals and most speech frequencies',
                    style: TextStyle(fontSize: 12, color: subtitleColor),
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
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Treble',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Softer', style: TextStyle(color: textColor)),
                    Text('Louder', style: TextStyle(color: textColor)),
                  ],
                ),
                Slider(
                  value: db_valueSB_TS,
                  onChanged: (value) {
                    setState(() => db_valueSB_TS = value);
                    _autoSave(settingName: 'Treble');
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
                    style: TextStyle(color: textColor),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enhances high frequencies like cymbals and consonant sounds',
                    style: TextStyle(fontSize: 12, color: subtitleColor),
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

  Widget _buildSoundEnhancementSection(Color textColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(
              Icons.add_sharp,
              color: textColor,
              size: 30,
            ),
            Text(
              ' Sound Enhancement',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ]),

          // Reduce Background Noise toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reduce Background Noise',
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Minimize constant background sounds',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reduce_background_noise,
                onChanged: (value) {
                  setState(() => reduce_background_noise = value);
                  _autoSave(settingName: 'Background Noise Reduction');
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Colors.grey,
              ),
            ],
          ),

          // Reduce Wind Noise toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reduce Wind Noise',
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Helps in outdoor environments',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reduce_wind_noise,
                onChanged: (value) {
                  setState(() => reduce_wind_noise = value);
                  _autoSave(settingName: 'Wind Noise Reduction');
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Colors.grey,
              ),
            ],
          ),

          // Soften Sudden Sounds toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Soften Sudden Sounds',
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Reduces unexpected loud noises',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: soften_sudden_noise,
                onChanged: (value) {
                  setState(() => soften_sudden_noise = value);
                  _autoSave(settingName: 'Sudden Sound Softening');
                },
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
