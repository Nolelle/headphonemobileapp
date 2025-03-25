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
    try {
      await BluetoothPlatform.startScan();
    } catch (e) {
      print("Failed to start scan: $e");
      // Don't rethrow to handle gracefully
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      await BluetoothPlatform.stopScan();
    } catch (e) {
      print("Error stopping scan: $e");
      // Don't rethrow to handle gracefully
    }
  }

  // Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      return await BluetoothPlatform.isBluetoothEnabled();
    } catch (e) {
      print("Failed to check if Bluetooth is enabled: $e");
      return false; // Default to false on error
    }
  }

  // Open Bluetooth settings
  Future<void> openBluetoothSettings() async {
    try {
      await BluetoothPlatform.platform.invokeMethod('openBluetoothSettings');
    } catch (e) {
      print("Error opening Bluetooth settings: $e");
      // Don't rethrow to handle gracefully
    }
  }

  Future<bool> connectToDevice(String deviceId) async {
    try {
      return await BluetoothPlatform.connectToDevice(deviceId);
    } catch (e) {
      print("Failed to connect to device: $e");
      return false; // Default to false on error
    }
  }

  Future<void> disconnectDevice() async {
    try {
      await BluetoothPlatform.disconnectDevice();
    } catch (e) {
      print("Failed to disconnect device: $e");
      // Don't rethrow to handle gracefully
    }
  }

  // Get scanned devices
  Future<List<BluetoothDevice>> getScannedDevices() async {
    try {
      return await BluetoothPlatform.getScannedDevices();
    } catch (e) {
      print("Failed to get scanned devices: $e");
      return []; // Return empty list on error
    }
  }
}
