// File: lib/features/bluetooth/platform/bluetooth_platform.dart

import 'package:flutter/services.dart';

enum BluetoothAudioType {
  none,
  classic,
  leAudio,
}

enum BluetoothDeviceType {
  classic,
  le,
  dual,
  unknown,
}

class BluetoothDevice {
  final String id;
  final String name;
  final BluetoothDeviceType type;
  final BluetoothAudioType? audioType;

  BluetoothDevice({
    required this.id,
    required this.name,
    required this.type,
    this.audioType,
  });

  factory BluetoothDevice.fromMap(Map<dynamic, dynamic> map) {
    BluetoothDeviceType deviceType;
    switch (map['type']) {
      case 'classic':
        deviceType = BluetoothDeviceType.classic;
        break;
      case 'le':
        deviceType = BluetoothDeviceType.le;
        break;
      case 'dual':
        deviceType = BluetoothDeviceType.dual;
        break;
      default:
        deviceType = BluetoothDeviceType.unknown;
    }

    BluetoothAudioType? audioType;
    if (map['audioType'] != null) {
      switch (map['audioType']) {
        case 'le_audio':
          audioType = BluetoothAudioType.leAudio;
          break;
        case 'classic':
          audioType = BluetoothAudioType.classic;
          break;
        default:
          audioType = BluetoothAudioType.none;
      }
    }

    return BluetoothDevice(
      id: map['id'],
      name: map['name'] ?? 'Unknown Device',
      type: deviceType,
      audioType: audioType,
    );
  }
}

class BluetoothPlatform {
  static const platform = MethodChannel('com.headphonemobileapp/bluetooth');

  // Check if Bluetooth is enabled
  static Future<bool> isBluetoothEnabled() async {
    try {
      return await platform.invokeMethod('isBluetoothEnabled');
    } on PlatformException catch (e) {
      print("Failed to check if Bluetooth is enabled: ${e.message}");
      return false;
    }
  }

  // Start scanning for devices
  static Future<void> startScan() async {
    try {
      await platform.invokeMethod('startScan');
    } on PlatformException catch (e) {
      print("Failed to start scan: ${e.message}");
      rethrow;
    }
  }

  // Stop scanning
  static Future<void> stopScan() async {
    try {
      await platform.invokeMethod('stopScan');
    } on PlatformException catch (e) {
      print("Failed to stop scan: ${e.message}");
      rethrow;
    }
  }

  // Get scanned devices
  static Future<List<BluetoothDevice>> getScannedDevices() async {
    try {
      final List<dynamic> result =
          await platform.invokeMethod('getScannedDevices');
      return result.map((device) => BluetoothDevice.fromMap(device)).toList();
    } on PlatformException catch (e) {
      print("Failed to get scanned devices: ${e.message}");
      return [];
    }
  }

  // Connect to device
  static Future<bool> connectToDevice(String deviceId) async {
    try {
      return await platform
          .invokeMethod('connectToDevice', {'deviceId': deviceId});
    } on PlatformException catch (e) {
      print("Failed to connect to device: ${e.message}");
      rethrow;
    }
  }

  // Disconnect device
  static Future<bool> disconnectDevice() async {
    try {
      return await platform.invokeMethod('disconnectDevice');
    } on PlatformException catch (e) {
      print("Failed to disconnect device: ${e.message}");
      rethrow;
    }
  }

  // Get connected device
  static Future<BluetoothDevice?> getConnectedDevice() async {
    try {
      final Map<dynamic, dynamic>? result =
          await platform.invokeMethod('getConnectedDevice');
      if (result != null) {
        return BluetoothDevice.fromMap(result);
      }
      return null;
    } on PlatformException catch (e) {
      print("Failed to get connected device: ${e.message}");
      return null;
    }
  }

  // Check if any audio device is connected
  static Future<bool> isAudioDeviceConnected() async {
    try {
      return await platform.invokeMethod('isAudioDeviceConnected');
    } on PlatformException catch (e) {
      print("Failed to check audio device connection: ${e.message}");
      return false;
    }
  }

  // Check if LE Audio device is connected
  static Future<bool> isLEAudioConnected() async {
    try {
      return await platform.invokeMethod('isLEAudioConnected');
    } on PlatformException catch (e) {
      print("Failed to check LE Audio connection: ${e.message}");
      return false;
    }
  }

  // Check if Classic Bluetooth audio is connected
  static Future<bool> isClassicAudioConnected() async {
    try {
      return await platform.invokeMethod('isClassicAudioConnected');
    } on PlatformException catch (e) {
      print("Failed to check Classic audio connection: ${e.message}");
      return false;
    }
  }

  // Force audio routing to Bluetooth
  static Future<void> forceAudioRoutingToBluetooth() async {
    try {
      await platform.invokeMethod('forceAudioRoutingToBluetooth');
    } on PlatformException catch (e) {
      print("Failed to force audio routing: ${e.message}");
    }
  }

  // Get Bluetooth audio connection type
  static Future<BluetoothAudioType> getBluetoothAudioType() async {
    try {
      final String result = await platform.invokeMethod('getBtConnectionType');
      switch (result) {
        case 'le_audio':
          return BluetoothAudioType.leAudio;
        case 'classic':
          return BluetoothAudioType.classic;
        default:
          return BluetoothAudioType.none;
      }
    } on PlatformException catch (e) {
      print("Failed to get Bluetooth audio type: ${e.message}");
      return BluetoothAudioType.none;
    }
  }
}
