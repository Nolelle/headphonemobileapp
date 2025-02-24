import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../views/screens/bluetooth_settings_page.dart';

class BluetoothWrapper extends StatelessWidget {
  final Widget child;

  const BluetoothWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, _) {
        if (!bluetoothProvider.isDeviceConnected) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Please connect your Bluetooth headphones',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BluetoothSettingsPage(),
                      ),
                    ),
                    child: const Text('Bluetooth Settings'),
                  ),
                ],
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
