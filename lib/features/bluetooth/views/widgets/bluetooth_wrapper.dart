// File: lib/features/bluetooth/views/widgets/bluetooth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import 'package:flutter/services.dart';

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
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bluetooth_searching,
                        size: 64,
                        color: Color.fromRGBO(133, 86, 169, 1.00),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Please connect your Bluetooth headphones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(93, 59, 129, 1.00),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'To use this app, you need to connect your Bluetooth headphones',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _isAttemptingConnection
                          ? _buildConnectionProgress()
                          : _buildConnectionButtons(bluetoothProvider),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return widget.child;
      },
    );
  }

  Widget _buildConnectionProgress() {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.fromRGBO(133, 86, 169, 1.00),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _statusMessage.isNotEmpty
              ? _statusMessage
              : 'Checking for connected devices...',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(93, 59, 129, 1.00),
            foregroundColor: Colors.white,
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
    );
  }

  Widget _buildConnectionButtons(BluetoothProvider bluetoothProvider) {
    return Column(
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
                  icon: const Icon(Icons.settings_bluetooth),
                  label: const Text('Open Bluetooth Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () async {
                    try {
                      // Simply open the Bluetooth settings without additional logic
                      const MethodChannel settingsChannel =
                          MethodChannel('com.headphonemobileapp/settings');
                      await settingsChannel
                          .invokeMethod('openBluetoothSettings');
                    } catch (e) {
                      print('Error opening Bluetooth settings: $e');

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Error opening Bluetooth settings: $e'),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check For Devices'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(
                      color: Color.fromRGBO(133, 86, 169, 1.00),
                    ),
                  ),
                  onPressed: () => _checkForDevices(bluetoothProvider),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Developer Options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.developer_mode),
                  label: const Text('Bypass Check'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  onPressed: () {
                    bluetoothProvider.setBypassBluetoothCheck(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bluetooth check bypassed',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _checkForDevices(BluetoothProvider bluetoothProvider) async {
    setState(() {
      _isAttemptingConnection = true;
      _statusMessage = 'Checking for connected devices...';
    });

    try {
      // Check connection multiple times with a delay
      await bluetoothProvider.checkBluetoothConnection();

      for (int i = 0; i < 3; i++) {
        if (bluetoothProvider.isDeviceConnected) break;

        setState(() {
          _statusMessage = 'Checking again (${i + 1}/3)...';
        });

        await Future.delayed(const Duration(seconds: 1));
        await bluetoothProvider.checkBluetoothConnection();
      }

      // Show final status message
      setState(() {
        _statusMessage = bluetoothProvider.isDeviceConnected
            ? 'Found connected device!'
            : 'No connected devices found';
      });

      // Wait a moment to show the result
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking devices';
      });
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      if (mounted) {
        setState(() {
          _isAttemptingConnection = false;
          _statusMessage = '';
        });
      }
    }
  }
}
