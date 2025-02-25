// File: lib/features/bluetooth/services/bluetooth_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import '../platform/bluetooth_platform.dart';
import 'package:flutter/foundation.dart';

class MyBluetoothService {
  // Start scanning for BLE devices
  Stream<List<ScanResult>> startScan() {
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
      androidScanMode: AndroidScanMode.lowLatency,
    );
    return FlutterBluePlus.scanResults;
  }

  // Stop scanning
  void stopScan() {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      print("Error stopping scan: $e");
    }
  }

  // Listen to Bluetooth state changes
  Stream<bool> listenToBluetoothState() {
    return FlutterBluePlus.adapterState
        .map((state) => state == BluetoothAdapterState.on);
  }

  Future<void> openBluetoothSettings() async {
    try {
      // For Android
      if (Platform.isAndroid) {
        const platform = MethodChannel('com.headphonemobileapp/settings');
        await platform.invokeMethod('openBluetoothSettings');
      } else {
        print("Opening Bluetooth settings not supported on this platform");
      }
    } catch (e) {
      print("Error opening Bluetooth settings: $e");
    }
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

  Future<void> connectToDeviceDirectly(BluetoothDevice device) async {
    try {
      print("Attempting direct connection to: ${device.name}");

      // Set a reasonable timeout
      await device
          .connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false, // Don't try to auto-connect, which can hang
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print("Connection attempt timed out");
          throw TimeoutException("Connection timed out");
        },
      );

      print("Connection successful to: ${device.name}");
    } catch (e) {
      print("Error in connectToDeviceDirectly: $e");
      // Make sure to disconnect if there was an error
      try {
        await device.disconnect();
      } catch (disconnectError) {
        print(
            "Error during disconnect after failed connection: $disconnectError");
      }
      rethrow;
    }
  }

  Future<List<BluetoothDevice>> getConnectedDevices() async {
    try {
      // Get connected BLE devices
      final devices = FlutterBluePlus.connectedDevices;

      if (devices.isNotEmpty) {
        print("Found ${devices.length} connected BLE devices");
        return devices;
      }

      // If no devices found, return empty list
      return [];
    } catch (e) {
      print("Error getting connected devices: $e");
      return [];
    }
  }
}
