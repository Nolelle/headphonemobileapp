// lib/features/bluetooth/services/bluetooth_service.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();
  await Permission.locationWhenInUse.request();
}

class MyBluetoothService {
  // Start scanning for BLE devices
  Stream<List<ScanResult>> startScan() {
    // Start scanning. It doesn't return a value, so we just call it.
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    // Return the stream of scan results that you can listen to
    return FlutterBluePlus.scanResults;
  }

  // Stop scanning
  void stopScan() {
    FlutterBluePlus.stopScan();
  }
}
