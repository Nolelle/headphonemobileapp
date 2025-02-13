import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider extends ChangeNotifier {
  // Private properties
  String _connectedDeviceName = "No Device";
  String _connectedDeviceID = "N/A";
  bool _isDeviceConnected = false;
  String _connectedDeviceBattery = "???";

  //getters
  String get connectedDeviceName => _connectedDeviceName;
  String get connectedDeviceID => _connectedDeviceID;
  bool get isDeviceConnected => _isDeviceConnected;
  String get connectedDeviceBattery => _connectedDeviceBattery;

  //setters
  set connectedDeviceName(String name) {
    _connectedDeviceName = name;
    notifyListeners();
  }

  set connectedDeviceID(String id) {
    _connectedDeviceID = id;
    notifyListeners();
  }

  set isDeviceConnected(bool status) {
    _isDeviceConnected = status;
    notifyListeners();
  }

  set connectedDeviceBattery(String batteryLevel) {
    _connectedDeviceBattery = batteryLevel;
    notifyListeners();
  }

  //check for a connected bluetooth device
  Future<void> checkConnectedDevice() async {
    List<BluetoothDevice> devices = FlutterBluePlus.connectedDevices;

    if (devices.isNotEmpty) {
      final device = devices.first;

      // Update the connected device details
      connectedDeviceName = device.platformName.isNotEmpty ? device.platformName : "Unnamed Device";
      connectedDeviceID = device.remoteId.str;
      isDeviceConnected = true;

      // Fetch battery level if supported (example characteristic UUID)
      try {
        final services = await device.discoverServices();
        for (var service in services) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
              final batteryLevel = await characteristic.read();
              connectedDeviceBattery = batteryLevel.isNotEmpty
                  ? '${batteryLevel.first}%'
                  : "???%";
            }
          }
        }
      } catch (e) {
        connectedDeviceBattery = "???%";//in case its not supported
      }
    } else {
      connectedDeviceName = "No Device";
      connectedDeviceID = "N/A";
      isDeviceConnected = false;
      connectedDeviceBattery = "???";
    }
  }
}
