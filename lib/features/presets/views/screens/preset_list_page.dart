import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  String connectedDeviceName = "CONNECTED_DEVICE_NAME";
  String connectedDeviceID = "CONNECTED_DEVICE_ID";
  bool connectedDeviceStatus = false;
  String connectedDeviceBattery = "???"; // Placeholder for now

  @override
  void initState() {
    super.initState();
    _fetchConnectedDeviceInfo();
  }

  Future<void> _fetchConnectedDeviceInfo() async {
    // Fetch connected devices
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;

    if (devices.isNotEmpty) {
      BluetoothDevice device = devices.first;

      setState(() {
        connectedDeviceName = device.name.isNotEmpty
            ? device.name
            : "Unnamed Device";
        connectedDeviceID = device.id.id;
        connectedDeviceStatus = true; // Assuming it's connected if listed
      });

      // Optionally, fetch additional details like battery if supported by your BLE device
    }
  }

  String _truncateConnectedDeviceName(String deviceName) {
    if (deviceName.length <= 20) {
      return deviceName;
    }
    return '${deviceName.substring(0, 20)}...';
  }

  String _displayConnectionStatus(bool deviceConnectionStatus) {
    return deviceConnectionStatus ? "Connected" : "N/A";
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

  @override
  Widget build(BuildContext context) {
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
                      _truncateConnectedDeviceName(connectedDeviceName),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      _displayConnectionStatus(connectedDeviceStatus),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      connectedDeviceID,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      '$connectedDeviceBattery%',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    )
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        onPressed: () async {
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
