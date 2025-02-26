import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../bluetooth/providers/bluetooth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bluetooth Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bluetooth Connection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${provider.isBluetoothEnabled ? 'Enabled' : 'Disabled'}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connected: ${provider.isDeviceConnected ? 'Yes' : 'No'}',
                      ),
                      const SizedBox(height: 4),
                      Text('Device: ${provider.connectedDeviceName}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            _openBluetoothSettings(context, provider),
                        child: const Text('Open Bluetooth Settings'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Developer Options
              const Text(
                'Developer Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text('Bypass Bluetooth Check'),
                subtitle: const Text(
                  'Enable this to use the app without a Bluetooth connection',
                ),
                value:
                    provider.isDeviceConnected && !provider.isBluetoothEnabled,
                onChanged: (value) {
                  provider.setBypassMode(value);
                },
              ),

              // App Info
              const SizedBox(height: 24),
              const Text(
                'App Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Version: 1.0.0'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBluetoothSettings(
      BuildContext context, BluetoothProvider provider) async {
    await provider.connectViaSystemSettings();
  }
}
