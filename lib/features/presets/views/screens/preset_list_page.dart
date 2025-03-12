import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './preset_page.dart';
import '../../providers/preset_provider.dart';
import '../../models/preset.dart';
import '../../../../l10n/app_localizations.dart';

class PresetsListPage extends StatefulWidget {
  final PresetProvider presetProvider;

  const PresetsListPage({
    super.key,
    required this.presetProvider,
  });

  @override
  State<PresetsListPage> createState() => _PresetsListPageState();
}

class _PresetsListPageState extends State<PresetsListPage> {
  String? activePresetId; // Tracks the currently active preset ID

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String presetName) async {
    final appLocalizations = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(appLocalizations.translate('confirm_delete')),
              content: Text(
                  '${appLocalizations.translate('confirm_delete_message')} "$presetName"?'),
              actions: <Widget>[
                TextButton(
                  child: Text(appLocalizations.translate('cancel')),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(appLocalizations.translate('delete')),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appLocalizations.translate('nav_presets')),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PresetProvider>(
              builder: (context, provider, child) {
                final presets = provider.presets.values.toList();

                if (presets.isEmpty) {
                  return Center(
                    child: Text(
                      appLocalizations.translate('no_presets'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    final isActive = preset.id == provider.activePresetId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                activePresetId = preset.id;
                              });

                              provider.setActivePreset(preset.id);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${preset.name} ${appLocalizations.translate('sent_to_device')}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive
                                  ? theme.colorScheme.secondary
                                  : theme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      preset.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (activePresetId == preset.id)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PresetPage(
                                          presetId: preset.id,
                                          presetName: preset.name,
                                          presetProvider: widget.presetProvider,
                                        ),
                                      ),
                                    );
                                  },
                                  child:
                                      Text(appLocalizations.translate('edit')),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                  ),
                                  onPressed: () async {
                                    final shouldDelete =
                                        await _showDeleteConfirmationDialog(
                                            context, preset.name);
                                    if (shouldDelete) {
                                      provider.deletePreset(preset.id);
                                      setState(() {
                                        activePresetId = null;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${preset.name} ${appLocalizations.translate('deleted_successfully')}'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                      appLocalizations.translate('delete')),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<PresetProvider>(
            builder: (context, provider, child) {
              final presetCount = provider.presets.length;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${appLocalizations.translate('presets_count')} $presetCount/10',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () async {
          final presetCount = widget.presetProvider.presets.length;
          if (presetCount >= 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appLocalizations.translate('max_presets')),
              ),
            );
            return;
          }

          final newId = 'preset_${DateTime.now().millisecondsSinceEpoch}';
          final newPreset = Preset(
            id: newId,
            name: 'New Preset',
            dateCreated: DateTime.now(),
            presetData: {
              'db_valueOV': 0.0,
              'db_valueSB_BS': 0.0,
              'db_valueSB_LMS': 0.0,
              'db_valueSB_MRS': 0.0,
              'db_valueSB_MHS': 0.0,
              'db_valueSB_TS': 0.0,
              'reduce_background_noise': false,
              'reduce_wind_noise': false,
              'soften_sudden_noise': false,
            },
          );

          await widget.presetProvider.createPreset(newPreset);

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PresetPage(
                  presetId: newId,
                  presetName: 'New Preset',
                  presetProvider: widget.presetProvider,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
