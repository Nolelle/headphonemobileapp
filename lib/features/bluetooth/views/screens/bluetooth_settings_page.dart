import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothSettingsPage extends StatefulWidget {
  const BluetoothSettingsPage({super.key});

  @override
  State<BluetoothSettingsPage> createState() => _BluetoothSettingsPageState();
}

class _BluetoothSettingsPageState extends State<BluetoothSettingsPage> {
  bool _isReconnecting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bluetooth Settings'),
            backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
            foregroundColor: Colors.white,
          ),
          backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Connection Status Section
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
                          style: TextStyle(
                            color: provider.isBluetoothEnabled
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Device: ${provider.isDeviceConnected ? provider.connectedDeviceName : 'Not Connected'}',
                          style: TextStyle(
                            color: provider.isDeviceConnected
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.registeredDeviceId != null) ...[
                          const Text('Registered Device:'),
                          Text(
                            provider.connectedDeviceName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: provider.isDeviceConnected
                                    ? () {
                                        provider.disconnectDevice();
                                      }
                                    : _isReconnecting
                                        ? null
                                        : () async {
                                            setState(() {
                                              _isReconnecting = true;
                                            });

                                            try {
                                              await provider.reconnectDevice();
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          'Failed to reconnect: $e')),
                                                );
                                              }
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _isReconnecting = false;
                                                });
                                              }
                                            }
                                          },
                                child: _isReconnecting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        provider.isDeviceConnected
                                            ? 'Disconnect'
                                            : provider.connectedDevice != null
                                                ? 'Reconnect'
                                                : 'Connect',
                                      ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: provider.deregisterDevice,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Deregister'),
                              ),
                            ],
                          ),
                        ] else
                          const Text('No device registered'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Scan Section
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
                      onPressed: provider.isScanning
                          ? provider.stopScan
                          : provider.startScan,
                      child: Text(
                        provider.isScanning ? 'Stop Scan' : 'Start Scan',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: provider.scanResults.isEmpty
                      ? Center(
                          child: provider.isScanning
                              ? const CircularProgressIndicator()
                              : const Text('No devices found'),
                        )
                      : ListView.builder(
                          itemCount: provider.scanResults.length,
                          itemBuilder: (context, index) {
                            final result = provider.scanResults[index];
                            final deviceName = result.device.name.isNotEmpty
                                ? result.device.name
                                : "Unknown Device (${result.device.id.toString().substring(0, 8)})";

                            return ListTile(
                              title: Text(deviceName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Signal Strength: ${result.rssi} dBm'),
                                  Text(result.device.id.toString()),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _connectToDevice(
                                    context, provider, result.device),
                                child: const Text('Connect'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // New method to handle connection workflow
  void _connectToDevice(BuildContext context, BluetoothProvider provider,
      BluetoothDevice device) async {
    // Show connecting indicator with cancel button
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text("Connecting to ${device.name}..."),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Try to cancel the connection attempt
                  try {
                    device.disconnect();
                  } catch (e) {
                    print("Error cancelling connection: $e");
                  }
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );

    try {
      // Attempt to connect to the device
      await provider.connectToDeviceDirectly(device);

      // Close the connecting dialog
      if (context.mounted) Navigator.of(context).pop();

      // If connection successful, ask if they want to register
      if (provider.isDeviceConnected && context.mounted) {
        final shouldRegister = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Device Connected'),
                  content: Text(
                      'Do you want to register "${device.name}" as your primary device?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('No'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Yes'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            ) ??
            false;

        if (shouldRegister) {
          provider.registerDevice(device);
        }
      }
    } catch (e) {
      // Close the connecting dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: ${e.toString()}')),
        );
      }
    }
  }
}
