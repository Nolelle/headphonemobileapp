import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../platform/bluetooth_platform.dart';

class BluetoothSettingsPage extends StatefulWidget {
  const BluetoothSettingsPage({super.key});

  @override
  State<BluetoothSettingsPage> createState() => _BluetoothSettingsPageState();
}

class _BluetoothSettingsPageState extends State<BluetoothSettingsPage> {
  bool _isScanning = false;
  bool _isConnecting = false;
  final bool _isRegistering = false;
  bool _bypassMode = false;

  @override
  void initState() {
    super.initState();
    // Check for existing connections when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BluetoothProvider>(context, listen: false);
      provider.checkBluetoothConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connection Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bluetooth: ${provider.isBluetoothEnabled ? 'Enabled' : 'Disabled'}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connected: ${provider.isDeviceConnected ? 'Yes' : 'No'}',
                      ),
                      const SizedBox(height: 4),
                      Text('Device: ${provider.connectedDeviceName}'),
                      const SizedBox(height: 4),
                      Text(
                          'Audio Type: ${_formatAudioType(provider.audioType)}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: provider.isDeviceConnected
                                ? () => _disconnectDevice(context, provider)
                                : null,
                            child: const Text('Disconnect'),
                          ),
                          ElevatedButton(
                            onPressed: provider.registeredDeviceId != null
                                ? () => _reconnectDevice(context, provider)
                                : null,
                            child: const Text('Reconnect'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // System Bluetooth Settings Button
              ElevatedButton.icon(
                onPressed: () => _openSystemSettings(context, provider),
                icon: const Icon(Icons.settings_bluetooth),
                label: const Text('Open System Bluetooth Settings'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

              const SizedBox(height: 16),

              // Scan Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isScanning
                        ? null
                        : () => _startScan(context, provider),
                    child: Text(_isScanning ? 'Scanning...' : 'Scan'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Device List
              _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : provider.scanResults.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No devices found'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.scanResults.length,
                          itemBuilder: (context, index) {
                            final device = provider.scanResults[index];
                            final deviceName = device.name.isNotEmpty
                                ? device.name
                                : "Unknown Device (${device.id.substring(0, 8)})";

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(deviceName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Device Type: ${_getDeviceTypeString(device.type)}'),
                                    Text('ID: ${device.id.substring(0, 8)}...'),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: _isConnecting
                                      ? null
                                      : () => _connectToDevice(
                                          context, provider, device),
                                  child: const Text('Connect'),
                                ),
                              ),
                            );
                          },
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
                  'Enable this to bypass Bluetooth connection requirements (for development only)',
                ),
                value: _bypassMode,
                onChanged: (value) {
                  setState(() {
                    _bypassMode = value;
                  });
                  provider.setBypassMode(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAudioType(BluetoothAudioType type) {
    switch (type) {
      case BluetoothAudioType.leAudio:
        return 'LE Audio';
      case BluetoothAudioType.classic:
        return 'Classic Bluetooth';
      case BluetoothAudioType.none:
        return 'None';
    }
  }

  String _getDeviceTypeString(BluetoothDeviceType type) {
    switch (type) {
      case BluetoothDeviceType.classic:
        return 'Classic';
      case BluetoothDeviceType.le:
        return 'LE';
      case BluetoothDeviceType.dual:
        return 'Dual Mode';
      case BluetoothDeviceType.unknown:
      default:
        return 'Unknown';
    }
  }

  Future<void> _startScan(
      BuildContext context, BluetoothProvider provider) async {
    if (!provider.isBluetoothEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable Bluetooth first')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      await provider.startScan();

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 5));

      setState(() {
        _isScanning = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning: $e')),
      );
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(BuildContext context,
      BluetoothProvider provider, BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await provider.connectToDevice(device);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _disconnectDevice(
      BuildContext context, BluetoothProvider provider) async {
    try {
      await provider.disconnectDevice();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device disconnected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to disconnect: $e')),
      );
    }
  }

  Future<void> _reconnectDevice(
      BuildContext context, BluetoothProvider provider) async {
    try {
      await provider.reconnectDevice();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device reconnected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reconnect: $e')),
      );
    }
  }

  Future<void> _openSystemSettings(
      BuildContext context, BluetoothProvider provider) async {
    await provider.connectViaSystemSettings();
  }
}
