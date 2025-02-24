import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/bluetooth_service.dart';

class BluetoothProvider extends ChangeNotifier {
  final MyBluetoothService _bluetoothService = MyBluetoothService();

  String _connectedDeviceName = "No Device";
  String? _registeredDeviceId;
  bool _isDeviceConnected = false;
  final String _connectedDeviceBattery = "???";
  bool _isEmulatorTestMode = false;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  // Getters
  String get connectedDeviceName => _connectedDeviceName;
  String? get registeredDeviceId => _registeredDeviceId;
  bool get isDeviceConnected => _isDeviceConnected || _isEmulatorTestMode;
  String get connectedDeviceBattery => _connectedDeviceBattery;
  bool get isEmulatorTestMode => _isEmulatorTestMode;
  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;

  BluetoothProvider() {
    initBluetoothStateListener();
    checkBluetoothConnection();
  }

  void initBluetoothStateListener() {
    _bluetoothService.listenToBluetoothState().listen((isOn) {
      if (isOn) {
        checkBluetoothConnection();
      } else {
        _isDeviceConnected = false;
        notifyListeners();
      }
    });
  }

  void setEmulatorTestMode(bool value) {
    _isEmulatorTestMode = value;
    notifyListeners();
  }

  Future<void> checkBluetoothConnection() async {
    if (_isEmulatorTestMode) return;

    try {
      final devices = await _bluetoothService.getConnectedDevices();
      _isDeviceConnected = devices.isNotEmpty;
      _connectedDeviceName =
          _isDeviceConnected ? devices.first.platformName : "No Device";
      notifyListeners();
    } catch (e) {
      print('Error checking Bluetooth connection: $e');
      _isDeviceConnected = false;
      notifyListeners();
    }
  }

  Future<void> openBluetoothSettings() async {
    await _bluetoothService.openBluetoothSettings();
  }

  // Device Registration Methods
  Future<void> registerDevice(BluetoothDevice device) async {
    _registeredDeviceId = device.id.toString();
    notifyListeners();
    // You might want to save this to persistent storage
  }

  Future<void> deregisterDevice() async {
    if (isDeviceConnected) {
      await disconnectDevice();
    }
    _registeredDeviceId = null;
    notifyListeners();
  }

  Future<void> connectToDevice() async {
    if (_registeredDeviceId == null) return;

    try {
      await _bluetoothService.connectToDevice(_registeredDeviceId!);
      _isDeviceConnected = true;
      notifyListeners();
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  Future<void> disconnectDevice() async {
    if (_registeredDeviceId == null) return;

    try {
      await _bluetoothService.disconnectDevice(_registeredDeviceId!);
      _isDeviceConnected = false;
      notifyListeners();
    } catch (e) {
      print('Error disconnecting from device: $e');
    }
  }

  // Scanning Methods
  Future<void> startScan() async {
    _isScanning = true;
    notifyListeners();

    _bluetoothService.startScan().listen(
      (results) {
        _scanResults = results;
        notifyListeners();
      },
      onError: (e) {
        print('Error scanning: $e');
        _isScanning = false;
        notifyListeners();
      },
      onDone: () {
        _isScanning = false;
        notifyListeners();
      },
    );
  }

  void stopScan() {
    _bluetoothService.stopScan();
    _isScanning = false;
    notifyListeners();
  }
}
