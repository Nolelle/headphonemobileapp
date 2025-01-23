// lib/features/bluetooth/views/screens/bluetooth_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../../providers/bluetooth_provider.dart';
import '../../services/bluetooth_service.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();
  await Permission.locationWhenInUse.request();
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final MyBluetoothService bluetoothService = MyBluetoothService();
  List<ScanResult> devices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
  }

  // Start scanning for devices
  void startScan() {
    setState(() {
      isScanning = true;
    });

    bluetoothService.startScan().listen((scanResults) {
      setState(() {
        devices = scanResults;
      });
    });
  }

  // Stop scanning for devices
  void stopScan() {
    bluetoothService.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Devices')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isScanning ? stopScan : startScan,
              child: Text(isScanning ? 'Stop Scanning' : 'Start Scanning'),
            ),
            SizedBox(height: 20),
            // Show the list of devices if any are found
            devices.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devices[index].device.name.isNotEmpty
                        ? devices[index].device.name
                        : 'Unnamed device'),
                    subtitle: Text(devices[index].device.id.toString()),
                  );
                },
              ),
            )
                : isScanning
                ? Center(child: CircularProgressIndicator())
                : Center(child: Text('No devices found')),
          ],
        ),
      ),
    );
  }
}
