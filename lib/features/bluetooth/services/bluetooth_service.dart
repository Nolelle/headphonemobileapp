// File: lib/features/bluetooth/services/bluetooth_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import '../platform/bluetooth_platform.dart';
import 'package:flutter/foundation.dart';

// This class is just a thin wrapper around BluetoothPlatform
class MyBluetoothService {
  // Start scanning for devices
  Future<void> startScan() async {
    await BluetoothPlatform.startScan();
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      await BluetoothPlatform.stopScan();
    } catch (e) {
      print("Error stopping scan: $e");
    }
  }

  // Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    return await BluetoothPlatform.isBluetoothEnabled();
  }

  // Open Bluetooth settings
  Future<void> openBluetoothSettings() async {
    try {
      await BluetoothPlatform.platform.invokeMethod('openBluetoothSettings');
    } catch (e) {
      print("Error opening Bluetooth settings: $e");
    }
  }

  Future<bool> connectToDevice(String deviceId) async {
    return await BluetoothPlatform.connectToDevice(deviceId);
  }

  Future<void> disconnectDevice() async {
    await BluetoothPlatform.disconnectDevice();
  }

  // Get scanned devices
  Future<List<BluetoothDevice>> getScannedDevices() async {
    return await BluetoothPlatform.getScannedDevices();
  }
}
