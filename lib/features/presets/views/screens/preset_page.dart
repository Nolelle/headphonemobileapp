import 'package:flutter/material.dart';
import 'dart:async'; // Add this import for Timer
import '../../providers/preset_provider.dart';
import '../../models/preset.dart';
import '../../../../l10n/app_localizations.dart';

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
  late FocusNode _nameFieldFocusNode;
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
    _nameFieldFocusNode = FocusNode();
    _nameFieldFocusNode.addListener(_onNameFieldFocusChange);
    _loadPresetData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFieldFocusNode.removeListener(_onNameFieldFocusChange);
    _nameFieldFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onNameFieldFocusChange() {
    // Save when focus is lost
    if (!_nameFieldFocusNode.hasFocus) {
      // Always save when focus is lost
      _autoSave(
          settingName: AppLocalizations.of(context).translate('preset_name'));
    }
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

  // Check if any values have changed compared to the original preset
  bool _hasChanges() {
    final preset = widget.presetProvider.presets[widget.presetId];
    if (preset == null) return false;

    final data = preset.presetData;

    // Compare current values with original values from the preset
    return db_valueOV != (data['db_valueOV'] ?? 0.0) ||
        db_valueSB_BS != (data['db_valueSB_BS'] ?? 0.0) ||
        db_valueSB_MRS != (data['db_valueSB_MRS'] ?? 0.0) ||
        db_valueSB_TS != (data['db_valueSB_TS'] ?? 0.0) ||
        reduce_background_noise != (data['reduce_background_noise'] ?? false) ||
        reduce_wind_noise != (data['reduce_wind_noise'] ?? false) ||
        soften_sudden_noise != (data['soften_sudden_noise'] ?? false) ||
        _nameController.text != preset.name;
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
        String message =
            '${_nameController.text} ${AppLocalizations.of(context).translate('successfully_updated')}';
        if (settingName != null) {
          message =
              '$settingName ${AppLocalizations.of(context).translate('updated')}';
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
                  ? '${AppLocalizations.of(context).translate('updating')} $settingName...'
                  : AppLocalizations.of(context).translate('updating')),
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
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.translate('edit_preset'),
          style: const TextStyle(
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

            // Ensure name field changes are saved if focus is still on the field
            if (_nameFieldFocusNode.hasFocus) {
              _nameFieldFocusNode.unfocus();
              // Let the focus listener handle saving if needed
            }

            // Only save and show notification if changes were made
            if (_hasChanges()) {
              // Use a different message for the back button case
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

              widget.presetProvider.updatePreset(preset).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${_nameController.text} ${appLocalizations.translate('successfully_updated')}'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                Navigator.of(context).pop();
              });
            } else {
              // No changes, just navigate back without saving or showing notification
              Navigator.of(context).pop();
            }
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
              _buildPresetNameSection(textColor, appLocalizations),
              _buildOverallVolumeSection(
                  textColor, subtitleColor, appLocalizations),
              _buildSoundBalanceSection(
                  textColor, subtitleColor, appLocalizations),
              _buildSoundEnhancementSection(
                  textColor, subtitleColor, appLocalizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetNameSection(
      Color textColor, AppLocalizations appLocalizations) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.translate('preset_name'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _nameController,
            focusNode: _nameFieldFocusNode,
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
              // No auto-save on every keystroke
            },
            onSubmitted: (_) {
              // Save when user presses enter/done
              _autoSave(settingName: appLocalizations.translate('preset_name'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverallVolumeSection(
      Color textColor, Color subtitleColor, AppLocalizations appLocalizations) {
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
              ' ${appLocalizations.translate('overall_volume')}',
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
              Text(appLocalizations.translate('softer'),
                  style: TextStyle(color: textColor)),
              Text(appLocalizations.translate('louder'),
                  style: TextStyle(color: textColor)),
            ],
          ),
          Slider(
            value: db_valueOV,
            onChanged: (value) {
              setState(() => db_valueOV = value);
            },
            onChangeEnd: (value) {
              // Always save when slider is released
              _autoSave(
                  settingName: appLocalizations.translate('overall_volume'));
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

  Widget _buildSoundBalanceSection(
      Color textColor, Color subtitleColor, AppLocalizations appLocalizations) {
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
              ' ${appLocalizations.translate('sound_balance')}',
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
                    appLocalizations.translate('bass'),
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
                    Text(appLocalizations.translate('softer'),
                        style: TextStyle(color: textColor)),
                    Text(appLocalizations.translate('louder'),
                        style: TextStyle(color: textColor)),
                  ],
                ),
                Slider(
                  value: db_valueSB_BS,
                  onChanged: (value) {
                    setState(() => db_valueSB_BS = value);
                  },
                  onChangeEnd: (value) {
                    _autoSave(settingName: appLocalizations.translate('bass'));
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
                    appLocalizations.translate('bass_description'),
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
                    appLocalizations.translate('mid'),
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
                    Text(appLocalizations.translate('softer'),
                        style: TextStyle(color: textColor)),
                    Text(appLocalizations.translate('louder'),
                        style: TextStyle(color: textColor)),
                  ],
                ),
                Slider(
                  value: db_valueSB_MRS,
                  onChanged: (value) {
                    setState(() => db_valueSB_MRS = value);
                  },
                  onChangeEnd: (value) {
                    _autoSave(settingName: appLocalizations.translate('mid'));
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
                    appLocalizations.translate('mid_description'),
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
                    appLocalizations.translate('treble'),
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
                    Text(appLocalizations.translate('softer'),
                        style: TextStyle(color: textColor)),
                    Text(appLocalizations.translate('louder'),
                        style: TextStyle(color: textColor)),
                  ],
                ),
                Slider(
                  value: db_valueSB_TS,
                  onChanged: (value) {
                    setState(() => db_valueSB_TS = value);
                  },
                  onChangeEnd: (value) {
                    _autoSave(
                        settingName: appLocalizations.translate('treble'));
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
                    appLocalizations.translate('treble_description'),
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

  Widget _buildSoundEnhancementSection(
      Color textColor, Color subtitleColor, AppLocalizations appLocalizations) {
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
              ' ${appLocalizations.translate('sound_enhancement')}',
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
                      appLocalizations.translate('reduce_background_noise'),
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    Text(
                      appLocalizations
                          .translate('reduce_background_noise_description'),
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
                  // Always save when switch is toggled
                  _autoSave(
                      settingName: appLocalizations
                          .translate('reduce_background_noise'));
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
                      appLocalizations.translate('reduce_wind_noise'),
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    Text(
                      appLocalizations
                          .translate('reduce_wind_noise_description'),
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
                  _autoSave(
                      settingName:
                          appLocalizations.translate('reduce_wind_noise'));
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
                      appLocalizations.translate('soften_sudden_sounds'),
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor,
                      ),
                    ),
                    Text(
                      appLocalizations
                          .translate('soften_sudden_sounds_description'),
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
                  _autoSave(
                      settingName:
                          appLocalizations.translate('soften_sudden_sounds'));
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
