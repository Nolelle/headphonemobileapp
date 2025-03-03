import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './preset_page.dart';
import '../../providers/preset_provider.dart';
import '../../models/preset.dart';

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

  Future<bool> _showDeleteConfirmationDialog(BuildContext context, String presetName) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$presetName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PresetProvider>(
              builder: (context, provider, child) {
                final presets = provider.presets.values.toList();
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
                                        '${preset.name} Successfully Sent To Device!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive
                                  ? const Color.fromRGBO(93, 59, 129, 1.00)
                                  : const Color.fromRGBO(133, 86, 169, 1.00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      preset.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
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
                                  child: const Text('Edit'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
                                  ),
                                  onPressed: () async {
                                    final shouldDelete = await _showDeleteConfirmationDialog(
                                        context, preset.name);
                                    if (shouldDelete) {
                                      provider.deletePreset(preset.id);
                                      setState(() {
                                        activePresetId = null;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${preset.name} deleted successfully!'),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Delete'),
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
                  'Presets: $presetCount/10',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        onPressed: () async {
          final presetCount = widget.presetProvider.presets.length;
          if (presetCount >= 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You can only have a maximum of 10 presets!'),
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
              'db_valueSB_MRS': 0.0,
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
