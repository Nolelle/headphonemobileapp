// File: lib/features/bluetooth/providers/bluetooth_provider.dart

import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

  // Add this getter to access the service
  MyBluetoothService get bluetoothService => _bluetoothService;

  BluetoothProvider({
    required MyBluetoothService bluetoothService,
    bool isEmulatorTestMode = false,
  })  : _bluetoothService = bluetoothService,
        _isEmulatorTestMode = isEmulatorTestMode {
    _init();
  }

  bool get isDeviceConnected => _isDeviceConnected || _isEmulatorTestMode;
  bool get isBluetoothEnabled => _isBluetoothEnabled || _isEmulatorTestMode;
  String get connectedDeviceName =>
      _isEmulatorTestMode ? "Emulator Test Device" : _connectedDeviceName;
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
      await device.connect(timeout: const Duration(seconds: 4));
      _connectedDevice = device;
      notifyListeners();
    } catch (e) {
      print('Error connecting directly to device: $e');
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
