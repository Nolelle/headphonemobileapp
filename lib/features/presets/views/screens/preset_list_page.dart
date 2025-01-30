import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../../../bluetooth/providers/bluetooth_provider.dart';
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
  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo(); // Fetch device info on initialization
  }

  Future<void> _fetchDeviceInfo() async {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);
    await bluetoothProvider.checkConnectedDevice();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connected device information
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bluetoothProvider.connectedDeviceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      bluetoothProvider.isDeviceConnected ? "Connected" : "No Device Connected",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: bluetoothProvider.isDeviceConnected
                            ? Colors.blue // Deep blue for connected
                            : Color.fromRGBO(93, 59, 129, 1.00), // Dark reddish-purple for disconnected
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bluetoothProvider.connectedDeviceID,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      bluetoothProvider.connectedDeviceBattery,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List of presets
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
                      child: ElevatedButton(
                        onPressed: () async {
                          final shouldActivate = await _showConfirmationDialog(
                              context, preset.name);

                          if (shouldActivate) {
                            provider.setActivePreset(preset.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '\'${preset.name}\' Successfully Sent To Device!'),
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PresetPage(
                                          presetId: preset.id,
                                          presetName: preset.name,
                                          presetProvider: provider,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String presetName) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Preset Activation'),
          content: Text('Do you want to send "$presetName" to your device?'),
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
}
