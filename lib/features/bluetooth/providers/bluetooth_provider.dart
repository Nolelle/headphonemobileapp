import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../platform/bluetooth_platform.dart';

class BluetoothProvider extends ChangeNotifier {
  bool _isDeviceConnected = false;
  bool _isBluetoothEnabled = false;
  String _connectedDeviceName = "No Device";
  String? _registeredDeviceId;
  final bool _isEmulatorTestMode;
  bool _isScanning = false;
  List<BluetoothDevice> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  bool _bypassBluetoothCheck = false;
  BluetoothAudioType _audioType = BluetoothAudioType.none;
  Timer? _bluetoothStateTimer;

  // Getters
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
  List<BluetoothDevice> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  BluetoothAudioType get audioType => _audioType;
  bool get isUsingLEAudio => _audioType == BluetoothAudioType.leAudio;

  // Constructor
  BluetoothProvider({
    bool isEmulatorTestMode = false,
  }) : _isEmulatorTestMode = isEmulatorTestMode {
    _init();
  }

// Inside the _init() method of BluetoothProvider
  void _init() async {
    if (_isEmulatorTestMode) {
      _isDeviceConnected = true;
      _isBluetoothEnabled = true;
      _connectedDeviceName = "Emulator Test Device";
      return;
    }

    // First, load saved connection state
    await loadConnectionState();

    // Setup periodic check for Bluetooth state
    _bluetoothStateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkBluetoothState();
    });

    // Initial checks - these will verify our loaded state
    await _checkBluetoothState();
    await checkBluetoothConnection();

    // Load registered device from storage
    await _loadRegisteredDevice();

    // Perform a delayed check after app initialization
    Future.delayed(const Duration(seconds: 3), () {
      checkBluetoothConnection();
    });
  }

  // Check Bluetooth state
  Future<void> _checkBluetoothState() async {
    final wasEnabled = _isBluetoothEnabled;
    _isBluetoothEnabled = await BluetoothPlatform.isBluetoothEnabled();

    if (wasEnabled != _isBluetoothEnabled) {
      notifyListeners();

      // If Bluetooth state changed, check for connections
      if (_isBluetoothEnabled) {
        await checkBluetoothConnection();
      } else {
        _isDeviceConnected = false;
        _connectedDeviceName = "No Device";
        _connectedDevice = null;
        notifyListeners();
      }
    }
  }

// Public method to save connection state
  Future<void> saveConnectionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_connectedDevice != null) {
        await prefs.setString('connected_device_id', _connectedDevice!.id);
        await prefs.setString('connected_device_name', _connectedDeviceName);
        await prefs.setBool('is_device_connected', _isDeviceConnected);
        await prefs.setInt('audio_type', _audioType.index);
      } else {
        // Clear connection data
        await prefs.remove('connected_device_id');
        await prefs.remove('connected_device_name');
        await prefs.setBool('is_device_connected', false);
        await prefs.setInt('audio_type', BluetoothAudioType.none.index);
      }
    } catch (e) {
      print('Error saving connection state: $e');
    }
  }

// Public method to load connection state
  Future<void> loadConnectionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get stored connection information
      final storedConnected = prefs.getBool('is_device_connected') ?? false;
      final storedDeviceId = prefs.getString('connected_device_id');
      final storedDeviceName =
          prefs.getString('connected_device_name') ?? "No Device";
      final storedAudioTypeIndex = prefs.getInt('audio_type') ?? 0;

      // Only set these as initial values, we'll verify with system after
      _connectedDeviceName = storedDeviceName;
      _isDeviceConnected = storedConnected;
      _audioType = BluetoothAudioType.values[storedAudioTypeIndex];

      // If we have a stored ID, remember it (this helps with reconnection)
      if (storedDeviceId != null) {
        _connectedDevice = BluetoothDevice(
          id: storedDeviceId,
          name: storedDeviceName,
          type: BluetoothDeviceType
              .unknown, // We don't know the type from storage
          audioType: BluetoothAudioType.values[storedAudioTypeIndex],
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error loading connection state: $e');
    }
  }

  // Method to update connection from another class
  Future<void> updateConnectionFromDevice(
      BluetoothDevice device, BluetoothAudioType audioType) async {
    _connectedDevice = device;
    _isDeviceConnected = true;
    _connectedDeviceName = device.name;
    _audioType = audioType;
    await saveConnectionState();
    notifyListeners();
  }

  Future<void> forceAudioRouting() async {
    if (_isEmulatorTestMode || _bypassBluetoothCheck) return;

    try {
      await BluetoothPlatform.forceAudioRoutingToBluetooth();

      // Attempt to verify audio connection after forcing routing
      await verifyAudioConnection();

      print('Forced audio routing to Bluetooth device');
    } catch (e) {
      print('Error forcing audio routing: $e');
      rethrow;
    }
  }

  // Load registered device from storage
  Future<void> _loadRegisteredDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _registeredDeviceId = prefs.getString('registered_device_id');

      if (_registeredDeviceId != null) {
        print("Found registered device ID: $_registeredDeviceId");
      }
    } catch (e) {
      print('Error loading registered device: $e');
    }
  }

  // Save registered device to storage
  Future<void> _saveRegisteredDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_registeredDeviceId != null) {
        await prefs.setString('registered_device_id', _registeredDeviceId!);
      } else {
        await prefs.remove('registered_device_id');
      }
    } catch (e) {
      print('Error saving registered device: $e');
    }
  }

  // Set bypass mode
  void setBypassMode(bool bypass) {
    _bypassBluetoothCheck = bypass;
    notifyListeners();
  }

  // Set bypass Bluetooth check (alias for setBypassMode for compatibility)
  void setBypassBluetoothCheck(bool bypass) {
    setBypassMode(bypass);
  }

  // Start scan for Bluetooth devices
  Future<void> startScan() async {
    if (_isEmulatorTestMode) {
      // Mock data for emulator
      _scanResults = [
        BluetoothDevice(
          id: "00:11:22:33:44:55",
          name: "Mock LE Audio Device",
          type: BluetoothDeviceType.le,
          audioType: BluetoothAudioType.leAudio,
        ),
        BluetoothDevice(
          id: "AA:BB:CC:DD:EE:FF",
          name: "Mock Classic Device",
          type: BluetoothDeviceType.classic,
          audioType: BluetoothAudioType.classic,
        ),
      ];
      notifyListeners();
      return;
    }

    try {
      _isScanning = true;
      notifyListeners();

      // Start the scan on the platform side
      await BluetoothPlatform.startScan();

      // Wait for scan to complete (5 seconds)
      await Future.delayed(const Duration(seconds: 5));

      // Get the results
      _scanResults = await BluetoothPlatform.getScannedDevices();

      _isScanning = false;
      notifyListeners();
    } catch (e) {
      print('Error scanning for devices: $e');
      _isScanning = false;
      notifyListeners();
      rethrow;
    }
  }

  // Stop scan
  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      await BluetoothPlatform.stopScan();
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }

  // Update scan results
  Future<void> _updateScanResults() async {
    try {
      _scanResults = await BluetoothPlatform.getScannedDevices();
      notifyListeners();
    } catch (e) {
      print('Error updating scan results: $e');
    }
  }

  // Check Bluetooth connection
  Future<void> checkBluetoothConnection() async {
    if (_isEmulatorTestMode) return;

    try {
      // Get the currently connected device from the platform
      _connectedDevice = await BluetoothPlatform.getConnectedDevice();

      // Update connection status
      _isDeviceConnected = _connectedDevice != null;
      _audioType = await BluetoothPlatform.getBluetoothAudioType();

      if (_isDeviceConnected && _connectedDevice != null) {
        _connectedDeviceName = _connectedDevice!.name;

        // If we have a connection but no registered device, register this one
        _registeredDeviceId ??= _connectedDevice!.id;
        await _saveRegisteredDevice();

        // Add indicator if it's LE Audio
        if (_audioType == BluetoothAudioType.leAudio) {
          _connectedDeviceName += " (LE Audio)";
        }

        print(
            "Connected to: $_connectedDeviceName with audio type: $_audioType");
      } else {
        _connectedDeviceName = "No Device";
      }

      notifyListeners();
    } catch (e) {
      print('Error checking Bluetooth connection: $e');
      _isDeviceConnected = false;
      notifyListeners();
    }
    await saveConnectionState();
  }

  // Register a device
  Future<void> registerDevice(BluetoothDevice device) async {
    if (_isEmulatorTestMode) return;

    try {
      // Try to connect to the device
      final connected = await BluetoothPlatform.connectToDevice(device.id);

      if (connected) {
        // Save the device ID
        _registeredDeviceId = device.id;
        _connectedDevice = device;
        _isDeviceConnected = true;
        _connectedDeviceName = device.name;

        // Store the device ID in persistent storage
        await _saveRegisteredDevice();

        // Check audio type
        _audioType = await BluetoothPlatform.getBluetoothAudioType();
        if (_audioType == BluetoothAudioType.leAudio) {
          _connectedDeviceName += " (LE Audio)";
        }

        notifyListeners();
        print('Successfully registered device: ${device.name}');
      } else {
        throw Exception("Failed to connect to device");
      }
    } catch (e) {
      print('Error registering device: $e');
      rethrow;
    }
    await saveConnectionState();
  }

  // Connect to a device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      final connected = await BluetoothPlatform.connectToDevice(device.id);

      if (connected) {
        _connectedDevice = device;
        _isDeviceConnected = true;
        _connectedDeviceName = device.name;

        // Check audio type
        _audioType = await BluetoothPlatform.getBluetoothAudioType();
        if (_audioType == BluetoothAudioType.leAudio) {
          _connectedDeviceName += " (LE Audio)";
        }

        notifyListeners();
      } else {
        throw Exception("Failed to connect to device");
      }
    } catch (e) {
      print('Error connecting to device: $e');
      rethrow;
    }
    await saveConnectionState();
  }

  // Disconnect device
  Future<void> disconnectDevice() async {
    if (_isEmulatorTestMode) return;

    try {
      await BluetoothPlatform.disconnectDevice();

      _isDeviceConnected = false;
      _connectedDeviceName = "No Device";
      _audioType = BluetoothAudioType.none;
      // Don't set _connectedDevice to null here to allow reconnection

      notifyListeners();
      print('Device disconnected successfully');
    } catch (e) {
      print('Error disconnecting device: $e');
      // Even if there's an error, update the UI state
      _isDeviceConnected = false;
      notifyListeners();
    }
    await saveConnectionState();
  }

  // Deregister device
  Future<void> deregisterDevice() async {
    try {
      if (_isDeviceConnected) {
        try {
          await BluetoothPlatform.disconnectDevice();
        } catch (e) {
          print('Error disconnecting device during deregistration: $e');
        }
      }

      _connectedDevice = null;
      _registeredDeviceId = null;
      _isDeviceConnected = false;
      _connectedDeviceName = "No Device";
      _audioType = BluetoothAudioType.none;

      // Clear from persistent storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('registered_device_id');

      notifyListeners();
      print('Device deregistered successfully');
    } catch (e) {
      print('Error deregistering device: $e');
    }
  }

  // Connect via system settings
  Future<void> connectViaSystemSettings() async {
    // Open Android's Bluetooth settings
    await BluetoothPlatform.platform.invokeMethod('openBluetoothSettings');

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

  // Reconnect to device
  Future<void> reconnectDevice() async {
    if (_isEmulatorTestMode) return;
    if (_connectedDevice == null && _registeredDeviceId == null) {
      throw Exception("No device to reconnect to");
    }

    try {
      print('Attempting to reconnect to device');

      bool connected = false;

      // Try to connect using the device object if available
      if (_connectedDevice != null) {
        connected =
            await BluetoothPlatform.connectToDevice(_connectedDevice!.id);
      }
      // Otherwise try using the registered device ID
      else if (_registeredDeviceId != null) {
        connected =
            await BluetoothPlatform.connectToDevice(_registeredDeviceId!);
      }

      if (!connected) {
        throw Exception("Failed to reconnect to device");
      }

      // Force audio routing to ensure audio works
      await BluetoothPlatform.forceAudioRoutingToBluetooth();

      // Verify the audio connection
      await verifyAudioConnection();

      if (!_isDeviceConnected) {
        throw Exception("Failed to establish audio connection");
      }

      notifyListeners();
      print('Successfully reconnected to device');
    } catch (e) {
      print('Error reconnecting to device: $e');
      rethrow;
    }
  }

  // Verify audio connection
  Future<bool> verifyAudioConnection() async {
    if (_isEmulatorTestMode || _bypassBluetoothCheck) return true;

    try {
      // Check what type of audio connection we have
      _audioType = await BluetoothPlatform.getBluetoothAudioType();

      // Check if any audio is actually connected
      final isAudioConnected = await BluetoothPlatform.isAudioDeviceConnected();

      // Update our internal state to match reality
      if (_isDeviceConnected != isAudioConnected) {
        _isDeviceConnected = isAudioConnected;
        notifyListeners();
      }

      return isAudioConnected;
    } catch (e) {
      print('Error verifying audio connection: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _bluetoothStateTimer?.cancel();
    super.dispose();
  }
}
