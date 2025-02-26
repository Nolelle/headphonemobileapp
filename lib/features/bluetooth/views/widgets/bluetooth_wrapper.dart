// File: lib/features/bluetooth/views/widgets/bluetooth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../screens/bluetooth_settings_page.dart';

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
            backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
            appBar: AppBar(
              title: const Text('Connect Bluetooth'),
              backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
              foregroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.bluetooth_searching,
                      size: 80,
                      color: Color.fromRGBO(133, 86, 169, 1.00),
                    ),
                    const SizedBox(height: 20),
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
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromRGBO(133, 86, 169, 1.00),
                                ),
                              ),
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
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(
                                            Icons.settings_bluetooth),
                                        label: const Text(
                                            'Open Android Bluetooth Settings'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                              133, 86, 169, 1.00),
                                          foregroundColor: Colors.white,
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
                                        label: const Text(
                                            'Check for Connected Devices'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color.fromRGBO(
                                              133, 86, 169, 1.00),
                                        ),
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
                                            if (!bluetoothProvider
                                                .isDeviceConnected) {
                                              for (int i = 0; i < 4; i++) {
                                                setState(() {
                                                  _statusMessage =
                                                      'Checking again (${i + 1}/4)...';
                                                });

                                                await Future.delayed(
                                                    const Duration(seconds: 1));
                                                await bluetoothProvider
                                                    .checkBluetoothConnection();

                                                if (bluetoothProvider
                                                    .isDeviceConnected) break;
                                              }
                                            }

                                            // Final status update
                                            setState(() {
                                              _statusMessage = bluetoothProvider
                                                      .isDeviceConnected
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
                                ),
                              ),

                              // Add bypass button
                              const SizedBox(height: 30),
                              const Divider(),
                              const SizedBox(height: 10),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Developer Options',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.developer_mode),
                                        label: const Text(
                                            'Bypass Bluetooth Check'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                        ),
                                        onPressed: () {
                                          // Set bypass mode to true
                                          bluetoothProvider
                                              .setBypassBluetoothCheck(true);

                                          // Show a snackbar to indicate bypass mode
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Bluetooth check bypassed. App running in developer mode.',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              backgroundColor: Colors.orange,
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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
