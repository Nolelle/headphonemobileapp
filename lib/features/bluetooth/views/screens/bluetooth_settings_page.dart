import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothSettingsPage extends StatelessWidget {
  const BluetoothSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Settings'),
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
      ),
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: Consumer<BluetoothProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Registered Device Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registered Device',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (provider.registeredDeviceId != null) ...[
                          Text('Device ID: ${provider.registeredDeviceId}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: provider.isDeviceConnected
                                    ? provider.disconnectDevice
                                    : provider.connectToDevice,
                                child: Text(
                                  provider.isDeviceConnected
                                      ? 'Disconnect'
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
                            return ListTile(
                              title: Text(
                                result.device.name.isNotEmpty
                                    ? result.device.name
                                    : 'Unknown Device',
                              ),
                              subtitle: Text(result.device.id.toString()),
                              trailing: ElevatedButton(
                                onPressed: () =>
                                    provider.registerDevice(result.device),
                                child: const Text('Register'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
