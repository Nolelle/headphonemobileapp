// File: lib/features/bluetooth/services/bluetooth_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import '../platform/bluetooth_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

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
    await device.connect();
  }

  Future<List<BluetoothDevice>> getConnectedDevices() async {
    try {
      // Try the direct API approach first
      final devices = FlutterBluePlus.connectedDevices;

      if (devices.isNotEmpty) {
        print("Found ${devices.length} connected BLE devices via API");
        return devices;
      }

      // If no devices found through the API, check if Android indicates connected audio devices
      final isAudioConnected = await isAudioDeviceConnected();
      if (isAudioConnected) {
        print("Audio device detected as connected!");

        // Do a quick scan to find nearby devices - if audio is connected
        // there should be a device with a strong signal nearby
        print("Scanning for nearby devices...");

        // Start a quick scan with high power
        FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 2),
          androidScanMode: AndroidScanMode.lowLatency,
        );

        // Wait for scan results
        await Future.delayed(const Duration(seconds: 3));

        // Get scan results
        final scanResults = await FlutterBluePlus.scanResults.first;

        // Find devices with strong signal
        final nearbyDevices = scanResults
            .where(
                (result) => result.rssi > -60) // Very strong signal threshold
            .map((result) => result.device)
            .toList();

        // Stop scan
        FlutterBluePlus.stopScan();

        if (nearbyDevices.isNotEmpty) {
          print(
              "Found ${nearbyDevices.length} nearby devices with strong signal");
          return nearbyDevices;
        }
      }

      // Fall back to checking if any audio devices are connected via system API
      return [];
    } catch (e) {
      print("Error getting connected devices: $e");
      return [];
    } finally {
      // Always make sure scan is stopped
      try {
        FlutterBluePlus.stopScan();
      } catch (_) {}
    }
  }

  Future<bool> isAudioDeviceConnected() async {
    try {
      // First check connected devices through FlutterBluePlus
      final connectedDevices = FlutterBluePlus.connectedDevices;

      // Check if any connected device is likely an audio device
      for (var device in connectedDevices) {
        final name = device.name.toLowerCase();
        if (name.contains('airpod') ||
            name.contains('headphone') ||
            name.contains('earphone') ||
            name.contains('headset') ||
            name.contains('speaker') ||
            name.contains('audio')) {
          return true;
        }
      }

      // Check via platform channel for system-connected audio devices
      final systemAudioConnected =
          await BluetoothPlatform.isAudioDeviceConnected();
      if (systemAudioConnected) {
        print("System audio device detected via native API!");
        return true;
      }

      // If still not found, fall back to scanning
      bool foundAudioDevice = false;

      FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 1),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      // Listen for scan results
      await for (List<ScanResult> results
          in FlutterBluePlus.scanResults.take(1)) {
        for (ScanResult result in results) {
          final name = result.device.name.toLowerCase();
          // Check if any scanned device is likely an audio device with strong signal
          if ((name.contains('airpod') ||
                  name.contains('headphone') ||
                  name.contains('earphone') ||
                  name.contains('headset') ||
                  name.contains('speaker') ||
                  name.contains('audio')) &&
              result.rssi > -70) {
            foundAudioDevice = true;
            break;
          }
        }
      }

      try {
        FlutterBluePlus.stopScan();
      } catch (_) {}

      return foundAudioDevice;
    } catch (e) {
      print('Error checking audio devices: $e');
      return false;
    } finally {
      // Always ensure scan is stopped
      try {
        FlutterBluePlus.stopScan();
      } catch (_) {}
    }
  }
}

class BluetoothService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;

  bool get isConnected => _connection != null && _connection!.isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<bool> get isBluetoothEnabled async {
    return await _bluetooth.isEnabled ?? false;
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      return [];
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      if (_connection!.isConnected) {
        _connectedDevice = device;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      return false;
    }
  }

  Future<void> disconnectDevice() async {
    try {
      if (_connection != null) {
        await _connection!.close();
        _connection = null;
        _connectedDevice = null;
      }
    } catch (e) {
      debugPrint('Error disconnecting device: $e');
    }
  }

  Future<void> sendData(String data) async {
    try {
      if (_connection != null && _connection!.isConnected) {
        _connection!.output.add(Uint8List.fromList(data.codeUnits));
        await _connection!.output.allSent;
      }
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }
}
