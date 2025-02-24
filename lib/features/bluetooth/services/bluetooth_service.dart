// lib/features/bluetooth/services/bluetooth_service.dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();
  await Permission.locationWhenInUse.request();
}

class MyBluetoothService {
  Stream<bool> listenToBluetoothState() {
    return FlutterBluePlus.adapterState
        .map((state) => state == BluetoothAdapterState.on);
  }

  Future<List<BluetoothDevice>> getConnectedDevices() async {
    return FlutterBluePlus.connectedDevices;
  }

  // Start scanning for BLE devices
  Stream<List<ScanResult>> startScan() {
    // Start scanning. It doesn't return a value, so we just call it.
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    // Return the stream of scan results that you can listen to
    return FlutterBluePlus.scanResults;
  }

  // Stop scanning
  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  Future<void> openBluetoothSettings() async {
    await LaunchApp.openApp(
        androidPackageName: "com.android.settings", openStore: false);
  }

  Future<void> connectToDevice(String deviceId) async {
    final devices = FlutterBluePlus.connectedDevices;
    final device = devices.firstWhere(
      (d) => d.id.toString() == deviceId,
      orElse: () => throw Exception('Device not found'),
    );
    await device.connect();
  }

  Future<void> disconnectDevice(String deviceId) async {
    final devices = FlutterBluePlus.connectedDevices;
    final device = devices.firstWhere(
      (d) => d.id.toString() == deviceId,
      orElse: () => throw Exception('Device not found'),
    );
    await device.disconnect();
  }
}
