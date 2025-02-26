import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './preset_page.dart';
import '../../providers/preset_provider.dart';
import '../../../bluetooth/providers/bluetooth_provider.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String presetName) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Preset Activation'),
              content:
                  Text('Do you want to send "$presetName" to your device?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Send'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String presetName) async {
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
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      appBar: AppBar(
        title: const Text('Presets'),
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PresetProvider>(
              builder: (context, provider, child) {
                final presets = provider.presets.values.toList();

                if (presets.isEmpty) {
                  return const Center(
                    child: Text(
                      'No presets available. Create a new preset to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
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
                            onPressed: () async {
                              final shouldActivate =
                                  await _showConfirmationDialog(
                                      context, preset.name);

                              if (shouldActivate) {
                                setState(() {
                                  activePresetId = preset
                                      .id; // Show dropdown for this preset
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
                              child: Text(
                                preset.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          if (provider.dropdownStates[preset.id] ?? false)
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.grey[200],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display preset data from presetData map
                                  Text(
                                      'Bass: ${preset.presetData['db_valueSB_BS'] ?? 0.0}'),
                                  Text(
                                      'Treble: ${preset.presetData['db_valueSB_TS'] ?? 0.0}'),
                                  Text(
                                      'Mid: ${preset.presetData['db_valueSB_MRS'] ?? 0.0}'),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PresetPage(
                                                presetId: preset.id,
                                                presetName: preset.name,
                                                presetProvider:
                                                    widget.presetProvider,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Edit'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final shouldDelete =
                                              await _showDeleteConfirmationDialog(
                                                  context, preset.name);
                                          if (shouldDelete) {
                                            await provider
                                                .deletePreset(preset.id);
                                          }
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create a new preset with default values
          final newId = 'preset_${DateTime.now().millisecondsSinceEpoch}';
          const newPresetName = 'New Preset';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PresetPage(
                presetId: newId,
                presetName: newPresetName,
                presetProvider: widget.presetProvider,
              ),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
