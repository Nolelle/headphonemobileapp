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
  int? _batteryLevel;
  Timer? _batteryCheckTimer;

  // Add timer for name retry
  Timer? _nameRetryTimer;
  int _nameRetryCount = 0;
  final int _maxNameRetries = 5;

  // Add timer for battery retry
  Timer? _batteryRetryTimer;
  int _batteryRetryCount = 0;
  final int _maxBatteryRetries = 3;

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
  int? get batteryLevel => _isEmulatorTestMode ? 85 : _batteryLevel;

  // Constructor
  BluetoothProvider({
    bool isEmulatorTestMode = false,
  }) : _isEmulatorTestMode = isEmulatorTestMode {
    _init();
  }

  void _init() async {
    if (_isEmulatorTestMode) {
      _isDeviceConnected = true;
      _isBluetoothEnabled = true;
      _connectedDeviceName = "Emulator Test Device";
      _batteryLevel = 85;
      return;
    }

    // First, load saved connection state
    await loadConnectionState();
    // If we loaded a connected state, respect it initially
    if (_isDeviceConnected) {
      notifyListeners();
    }

    // Setup periodic check for Bluetooth state
    _bluetoothStateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkBluetoothState();
    });

    // Setup periodic check for battery level
    _batteryCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isDeviceConnected) {
        _updateBatteryLevel();
      }
    });

    // Initial checks with delay to let Bluetooth system initialize
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkBluetoothState();

    // Load registered device from storage
    await _loadRegisteredDevice();

    // Multiple connection checks with increasing delays
    // This gives Android Bluetooth subsystem time to recognize connections
    for (var delay in [1, 2, 5]) {
      await Future.delayed(Duration(seconds: delay));
      await checkBluetoothConnection();

      // If connected, no need for further checks
      if (_isDeviceConnected) break;
    }

    // Initial battery level check if connected
    if (_isDeviceConnected) {
      await _updateBatteryLevel();
    }
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
        _batteryLevel = null;
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
        if (_batteryLevel != null) {
          await prefs.setInt('battery_level', _batteryLevel!);
        }
      } else {
        // Clear connection data
        await prefs.remove('connected_device_id');
        await prefs.remove('connected_device_name');
        await prefs.setBool('is_device_connected', false);
        await prefs.setInt('audio_type', BluetoothAudioType.none.index);
        await prefs.remove('battery_level');
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
      final storedBatteryLevel = prefs.getInt('battery_level');

      // Only set these as initial values, we'll verify with system after
      _connectedDeviceName = storedDeviceName;
      _isDeviceConnected = storedConnected;
      _audioType = BluetoothAudioType.values[storedAudioTypeIndex];
      _batteryLevel = storedBatteryLevel;

      // If we have a stored ID, remember it (this helps with reconnection)
      if (storedDeviceId != null) {
        _connectedDevice = BluetoothDevice(
          id: storedDeviceId,
          name: storedDeviceName,
          type: BluetoothDeviceType
              .unknown, // We don't know the type from storage
          audioType: BluetoothAudioType.values[storedAudioTypeIndex],
          batteryLevel: storedBatteryLevel,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error loading connection state: $e');
    }
  }

  // Update battery level
  Future<void> _updateBatteryLevel() async {
    if (!_isDeviceConnected) return;

    try {
      final batteryLevel = await BluetoothPlatform.getBatteryLevel();
      if (batteryLevel != _batteryLevel) {
        _batteryLevel = batteryLevel;
        notifyListeners();
        await saveConnectionState();
      }

      // If battery level is null and we don't have a retry timer running, start one
      if (batteryLevel == null && _batteryRetryTimer == null) {
        // Start retry timer for battery level
        print("Starting battery level retry timer");
        _batteryRetryCount = 0;
        _batteryRetryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
          retryGetBatteryLevel();
        });
      } else if (batteryLevel != null) {
        // If we got a valid battery level, cancel any retry timer
        _cancelBatteryRetryTimer();
      }
    } catch (e) {
      print('Error updating battery level: $e');
    }
  }

  // Force battery level update
  Future<void> refreshBatteryLevel() async {
    await _updateBatteryLevel();
  }

  // Method to retry getting battery level
  Future<void> retryGetBatteryLevel() async {
    if (!_isDeviceConnected || _isEmulatorTestMode || _bypassBluetoothCheck)
      return;

    print("Retrying to get battery level, attempt: ${_batteryRetryCount + 1}");
    final updatedBatteryLevel = await BluetoothPlatform.retryGetBatteryLevel();

    if (updatedBatteryLevel != null) {
      _batteryLevel = updatedBatteryLevel;
      print("Successfully updated battery level to: $_batteryLevel");
      notifyListeners();
      await saveConnectionState();

      // Cancel further retries as we succeeded
      _cancelBatteryRetryTimer();
    } else {
      _batteryRetryCount++;
      print(
          "Battery retry attempt $_batteryRetryCount failed, will retry again if under max retries");

      // Stop retrying after max attempts
      if (_batteryRetryCount >= _maxBatteryRetries) {
        print("Reached max battery retry attempts. Stopping retries.");
        _cancelBatteryRetryTimer();
      }
    }
  }

  // Helper to cancel the battery retry timer
  void _cancelBatteryRetryTimer() {
    _batteryRetryTimer?.cancel();
    _batteryRetryTimer = null;
    _batteryRetryCount = 0;
  }

  // Method to update connection from another class
  Future<void> updateConnectionFromDevice(
      BluetoothDevice device, BluetoothAudioType audioType) async {
    _connectedDevice = device;
    _isDeviceConnected = true;
    _connectedDeviceName = device.name;
    _audioType = audioType;
    _batteryLevel = device.batteryLevel;
    await saveConnectionState();
    notifyListeners();

    // Update battery level after connection
    await _updateBatteryLevel();
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

  // Add a method to retry getting the device name
  Future<void> retryGetDeviceName() async {
    if (!_isDeviceConnected || _isEmulatorTestMode || _bypassBluetoothCheck)
      return;

    // Only retry if the current name is Unknown Device
    if (_connectedDeviceName == "Unknown Device" ||
        _connectedDeviceName == "No Device") {
      print("Retrying to get device name, attempt: ${_nameRetryCount + 1}");
      final updatedDevice = await BluetoothPlatform.retryGetDeviceName();

      if (updatedDevice != null &&
          updatedDevice.name != "Unknown Device" &&
          updatedDevice.name != "No Device") {
        _connectedDevice = updatedDevice;
        _connectedDeviceName = updatedDevice.name;
        print("Successfully updated device name to: $_connectedDeviceName");
        notifyListeners();
        await saveConnectionState();

        // Cancel further retries as we succeeded
        _cancelNameRetryTimer();
      } else {
        _nameRetryCount++;
        print(
            "Name retry attempt $_nameRetryCount failed, will retry again if under max retries");

        // Stop retrying after max attempts
        if (_nameRetryCount >= _maxNameRetries) {
          print("Reached max retry attempts. Stopping retries.");
          _cancelNameRetryTimer();
        }
      }
    } else {
      // We already have a proper name, cancel retries
      _cancelNameRetryTimer();
    }
  }

  // Helper to cancel the retry timer
  void _cancelNameRetryTimer() {
    _nameRetryTimer?.cancel();
    _nameRetryTimer = null;
    _nameRetryCount = 0;
  }

  // Modify checkBluetoothConnection to start the retry timer if needed
  Future<void> checkBluetoothConnection() async {
    if (_isEmulatorTestMode) return;

    try {
      // Try multiple approaches to detect connected devices

      // First approach: Get currently connected device from platform
      _connectedDevice = await BluetoothPlatform.getConnectedDevice();

      // Second approach: Check if any audio device is connected
      final isAudioConnected = await BluetoothPlatform.isAudioDeviceConnected();

      // Third approach: Check system audio routing status
      _audioType = await BluetoothPlatform.getBluetoothAudioType();

      // Update connection status based on combined results
      final wasConnected = _isDeviceConnected;
      _isDeviceConnected = _connectedDevice != null || isAudioConnected;

      // Log what we found for debugging
      print("Connected device: $_connectedDevice");
      print("Audio connected: $isAudioConnected");
      print("Audio type: $_audioType");

      // If device state changed from connected to disconnected, cancel any retry timers
      if (wasConnected && !_isDeviceConnected) {
        _cancelNameRetryTimer();
        _cancelBatteryRetryTimer();
        _batteryLevel = null;
      }

      if (_isDeviceConnected && _connectedDevice != null) {
        _connectedDeviceName = _connectedDevice!.name;

        // Start retry timer if we got an unknown device name
        if (_connectedDeviceName == "Unknown Device" ||
            _connectedDeviceName == "No Device") {
          // Cancel any existing retry timer
          _cancelNameRetryTimer();

          // Start a new retry timer that attempts every 2 seconds
          print("Starting device name retry timer");
          _nameRetryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
            retryGetDeviceName();
          });
        }

        // Check battery level on connection
        await _updateBatteryLevel();
      } else if (!_isDeviceConnected) {
        // Clear battery level when disconnected
        _batteryLevel = null;
      }

      notifyListeners();
    } catch (e) {
      print('Error checking Bluetooth connection: $e');
      _isDeviceConnected = false;
      _batteryLevel = null;

      // Cancel retry timers on error
      _cancelNameRetryTimer();
      _cancelBatteryRetryTimer();

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
      _batteryLevel = null;

      // Cancel any retry timers
      _cancelNameRetryTimer();
      _cancelBatteryRetryTimer();

      // Don't set _connectedDevice to null here to allow reconnection

      notifyListeners();
      print('Device disconnected successfully');
    } catch (e) {
      print('Error disconnecting device: $e');
      // Even if there's an error, update the UI state
      _isDeviceConnected = false;
      _batteryLevel = null;
      _cancelNameRetryTimer();
      _cancelBatteryRetryTimer();
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
      _batteryLevel = null;

      // Cancel any retry timers
      _cancelNameRetryTimer();
      _cancelBatteryRetryTimer();

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

  // Dispose method to clean up resources
  @override
  void dispose() {
    // Cancel all timers
    _bluetoothStateTimer?.cancel();
    _batteryCheckTimer?.cancel();
    _nameRetryTimer?.cancel();
    _batteryRetryTimer?.cancel();

    super.dispose();
  }
}
