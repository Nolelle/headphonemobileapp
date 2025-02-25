// File: lib/features/bluetooth/views/widgets/bluetooth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';

class BluetoothWrapper extends StatefulWidget {
  final Widget child;

  const BluetoothWrapper({super.key, required this.child});

  @override
  State<BluetoothWrapper> createState() => _BluetoothWrapperState();
}

class _BluetoothWrapperState extends State<BluetoothWrapper> {
  bool _isAttemptingConnection = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, _) {
        if (!bluetoothProvider.isDeviceConnected) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Please connect your Bluetooth headphones',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'To use this app, you need to connect Bluetooth headphones through your Android settings.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    _isAttemptingConnection
                        ? Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 20),
                              Text(
                                _statusMessage.isNotEmpty
                                    ? _statusMessage
                                    : 'Checking for connected devices...',
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[100],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isAttemptingConnection = false;
                                    _statusMessage = '';
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.settings_bluetooth),
                                label: const Text(
                                    'Open Android Bluetooth Settings'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isAttemptingConnection = true;
                                    _statusMessage =
                                        'Opening Bluetooth settings...';
                                  });

                                  // Open settings and wait for connection
                                  await bluetoothProvider
                                      .connectViaSystemSettings();

                                  setState(() {
                                    _statusMessage =
                                        'Checking for Bluetooth devices...';
                                  });

                                  // Force an additional connection check
                                  await bluetoothProvider
                                      .checkBluetoothConnection();

                                  setState(() {
                                    _isAttemptingConnection = false;
                                    _statusMessage = '';
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label:
                                    const Text('Check for Connected Devices'),
                                onPressed: () async {
                                  // Manually trigger a connection check
                                  setState(() {
                                    _isAttemptingConnection = true;
                                    _statusMessage =
                                        'Checking for connected devices...';
                                  });

                                  try {
                                    // Use the same multiple-check approach as in connectViaSystemSettings
                                    await bluetoothProvider
                                        .checkBluetoothConnection();

                                    // If not connected on first try, retry a few times with delay
                                    if (!bluetoothProvider.isDeviceConnected) {
                                      for (int i = 0; i < 4; i++) {
                                        setState(() {
                                          _statusMessage =
                                              'Checking again (${i + 1}/4)...';
                                        });

                                        await Future.delayed(
                                            const Duration(seconds: 1));
                                        await bluetoothProvider
                                            .checkBluetoothConnection();

                                        if (bluetoothProvider.isDeviceConnected)
                                          break;
                                      }
                                    }

                                    // Final status update
                                    setState(() {
                                      _statusMessage =
                                          bluetoothProvider.isDeviceConnected
                                              ? 'Found connected device!'
                                              : 'No connected devices found';
                                    });

                                    // Wait a moment to show the result
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                  } catch (e) {
                                    setState(() {
                                      _statusMessage = 'Error: $e';
                                    });
                                    await Future.delayed(
                                        const Duration(seconds: 2));
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isAttemptingConnection = false;
                                        _statusMessage = '';
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
        }
        return widget.child;
      },
    );
  }
}
