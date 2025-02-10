import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  // Singleton instance for the BluetoothManager
  static final BluetoothManager _instance = BluetoothManager._internal();
  factory BluetoothManager() => _instance;
  BluetoothManager._internal();

  bool get bluetoothDeviceConnected => false;

  // Function to start scanning for Bluetooth devices
  void startScanning() {
    // Using FlutterBluePlus directly, no instance variable needed
    FlutterBluePlus.scan().listen((scanResult) {
      print('Found device: ${scanResult.device.name}');
    }, onError: (error) {
      print('Error while scanning: $error');
    });
  }

  // Function to stop scanning for devices
  void stopScanning() {
    // Stop scanning directly using FlutterBluePlus
    FlutterBluePlus.stopScan();  // Directly call stopScan
    print("Stopped scanning for devices.");
  }

  // Function to check currently connected devices
  Future<void> checkConnectedDevices() async {
    // Directly use FlutterBluePlus to get connected devices
    List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      for (BluetoothDevice device in connectedDevices) {
        print("Connected device: ${device.name}");
      }
    } else {
      print("No devices are currently connected.");
    }
  }
}
