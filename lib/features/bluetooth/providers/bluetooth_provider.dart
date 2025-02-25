// File: lib/features/bluetooth/providers/bluetooth_provider.dart

import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async'; // Add this import for TimeoutException

class BluetoothProvider extends ChangeNotifier {
  final MyBluetoothService _bluetoothService;
  bool _isDeviceConnected = false;
  bool _isBluetoothEnabled = false;
  String _connectedDeviceName = "No Device";
  String? _registeredDeviceId;
  final bool _isEmulatorTestMode;
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  bool _bypassBluetoothCheck = false;

  // Add this getter to access the service
  MyBluetoothService get bluetoothService => _bluetoothService;

  // Add this getter and setter for bypass
  bool get bypassBluetoothCheck => _bypassBluetoothCheck;

  void setBypassBluetoothCheck(bool value) {
    _bypassBluetoothCheck = value;
    notifyListeners();
  }

  BluetoothProvider({
    required MyBluetoothService bluetoothService,
    bool isEmulatorTestMode = false,
  })  : _bluetoothService = bluetoothService,
        _isEmulatorTestMode = isEmulatorTestMode {
    _init();
  }

  bool get isDeviceConnected =>
      _isDeviceConnected || _isEmulatorTestMode || _bypassBluetoothCheck;
  bool get isBluetoothEnabled =>
      _isBluetoothEnabled || _isEmulatorTestMode || _bypassBluetoothCheck;
  String get connectedDeviceName {
    if (_isEmulatorTestMode) return "Emulator Test Device";
    if (_bypassBluetoothCheck) return "Bypass Mode";
    return _connectedDeviceName;
  }

  String? get registeredDeviceId => _registeredDeviceId;
  bool get isScanning => _isScanning;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  void _init() async {
    if (_isEmulatorTestMode) {
      _isDeviceConnected = true;
      _isBluetoothEnabled = true;
      _connectedDeviceName = "Emulator Test Device";
      return;
    }

    // Listen to Bluetooth state changes
    _bluetoothService.listenToBluetoothState().listen((isEnabled) {
      _isBluetoothEnabled = isEnabled;
      notifyListeners();

      // If Bluetooth is enabled, check for connected devices
      if (isEnabled) {
        checkBluetoothConnection();
      } else {
        _isDeviceConnected = false;
        _connectedDeviceName = "No Device";
        notifyListeners();
      }
    });

    // Initial check for connected devices
    await checkBluetoothConnection();
  }

  Future<void> checkBluetoothConnection() async {
    if (_isEmulatorTestMode) return;

    try {
      print("Checking for Bluetooth connections...");
      final devices = await _bluetoothService.getConnectedDevices();

      if (devices.isNotEmpty) {
        print("Found connected devices: ${devices.map((d) => d.name)}");
      }

      _isDeviceConnected = devices.isNotEmpty;

      if (_isDeviceConnected) {
        _connectedDeviceName = devices.first.name.isNotEmpty
            ? devices.first.name
            : devices.first.platformName;

        // Auto-register the connected device if none is registered
        _registeredDeviceId ??= devices.first.id.toString();
        print("Connected to: $_connectedDeviceName");
      } else {
        _connectedDeviceName = "No Device";
      }

      notifyListeners();
    } catch (e) {
      print('Error checking Bluetooth connection: $e');
      _isDeviceConnected = false;
      notifyListeners();
    }
  }

  Future<void> registerDevice(BluetoothDevice device) async {
    if (_isEmulatorTestMode) return;

    try {
      _registeredDeviceId = device.id.toString();
      notifyListeners();
    } catch (e) {
      print('Error registering device: $e');
    }
  }

  Future<void> connectToRegisteredDevice() async {
    if (_isEmulatorTestMode || _registeredDeviceId == null) return;

    try {
      await _bluetoothService.connectToDevice(_registeredDeviceId!);
      await checkBluetoothConnection();
    } catch (e) {
      print('Error connecting to registered device: $e');
    }
  }

  Future<void> disconnectDevice() async {
    if (_isEmulatorTestMode || _registeredDeviceId == null) return;

    try {
      await _bluetoothService.disconnectDevice(_registeredDeviceId!);
      _isDeviceConnected = false;
      _connectedDeviceName = "No Device";
      notifyListeners();
    } catch (e) {
      print('Error disconnecting device: $e');
    }
  }

  Future<void> connectViaSystemSettings() async {
    // Open Android's Bluetooth settings
    await _bluetoothService.openBluetoothSettings();

    // Check connection immediately after returning
    await checkBluetoothConnection();

    // If not connected yet, try checking a few more times with a delay
    if (!_isDeviceConnected) {
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 1));
        print("Checking again for Bluetooth connections...");
        await checkBluetoothConnection();
        if (_isDeviceConnected) break;
      }
    }
  }

  Future<void> startScan() async {
    if (_isScanning) return;
    _scanResults.clear();
    _isScanning = true;
    notifyListeners();

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        notifyListeners();
      });
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      notifyListeners();
    } catch (e) {
      print('Error connecting to device: $e');
      rethrow;
    }
  }

  Future<void> connectToDeviceDirectly(BluetoothDevice device) async {
    try {
      print("Attempting to connect to device: ${device.name}");

      // Add a timeout to prevent hanging
      await Future.any([
        _bluetoothService.connectToDeviceDirectly(device),
        Future.delayed(const Duration(seconds: 20)).then((_) {
          throw TimeoutException(
              "Connection attempt timed out after 20 seconds");
        }),
      ]);

      _connectedDevice = device;

      // Update connection status
      _isDeviceConnected = true;
      _connectedDeviceName = device.name.isNotEmpty
          ? device.name
          : "Unknown Device (${device.id.toString().substring(0, 8)})";

      notifyListeners();
      print("Successfully connected to: ${device.name}");
    } catch (e) {
      print('Error connecting directly to device: $e');
      // Reset connection status
      _isDeviceConnected = false;
      _connectedDevice = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deregisterDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      notifyListeners();
    }
  }
}
