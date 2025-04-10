import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';

class MockBluetoothPlatform extends Mock {
  static MockBluetoothPlatform? _instance;
  bool _isBluetoothEnabled = true;
  BluetoothDevice? _connectedDevice;
  bool _isAudioDeviceConnected = false;
  BluetoothAudioType _audioType = BluetoothAudioType.none;
  List<BluetoothDevice> _scannedDevices = [];
  int? _batteryLevel;
  bool _isScanning = false;

  // Additional flags for testing error scenarios
  bool _scanToThrowError = false;
  bool _connectionCheckToThrowError = false;
  bool _connectSuccess = true;
  bool _disconnectSuccess = true;
  bool _disconnectToThrowError = false;
  bool _forceAudioRoutingToThrowError = false;

  static final MethodChannel channel = BluetoothPlatform.platform;

  static void setup() {
    _instance = MockBluetoothPlatform();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      _instance!._handleMethodCall,
    );
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'isBluetoothEnabled':
        return _isBluetoothEnabled;
      case 'getConnectedDevice':
        if (_connectionCheckToThrowError) {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error during connection check',
          );
        }

        if (_connectedDevice == null) return null;
        return {
          'id': _connectedDevice!.id,
          'name': _connectedDevice!.name,
          'type': _connectedDevice!.type.toString().split('.').last,
          'audioType': _connectedDevice!.audioType.toString().split('.').last,
          'batteryLevel': _connectedDevice!.batteryLevel,
        };
      case 'isAudioDeviceConnected':
        return _isAudioDeviceConnected;
      case 'getBtConnectionType':
        switch (_audioType) {
          case BluetoothAudioType.leAudio:
            return 'le_audio';
          case BluetoothAudioType.classic:
            return 'classic';
          default:
            return 'none';
        }
      case 'startScan':
        if (_scanToThrowError) {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error during scan',
          );
        }
        _isScanning = true;
        return null;
      case 'stopScan':
        _isScanning = false;
        return null;
      case 'getScannedDevices':
        return _scannedDevices
            .map((device) => {
                  'id': device.id,
                  'name': device.name,
                  'type': device.type.toString().split('.').last,
                  'audioType': device.audioType.toString().split('.').last,
                  'batteryLevel': device.batteryLevel,
                })
            .toList();
      case 'getBatteryLevel':
        return _batteryLevel;
      case 'forceAudioRoutingToBluetooth':
        if (_forceAudioRoutingToThrowError) {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Error forcing audio routing',
          );
        }
        return null;
      case 'connectToDevice':
        final deviceId = call.arguments['deviceId'];
        if (!_connectSuccess) {
          return false;
        }
        return true;
      case 'disconnectDevice':
        if (_disconnectToThrowError) {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Error disconnecting device',
          );
        }
        return _disconnectSuccess;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The mock doesn't implement the method: ${call.method}",
        );
    }
  }

  static MockBluetoothPlatform get instance => _instance!;

  void setBluetoothEnabled(bool enabled) {
    _isBluetoothEnabled = enabled;
  }

  void setConnectedDevice(BluetoothDevice? device) {
    _connectedDevice = device;
    _isAudioDeviceConnected = device != null;
    _audioType = device?.audioType ?? BluetoothAudioType.none;
  }

  void setAudioType(BluetoothAudioType type) {
    _audioType = type;
  }

  void setScannedDevices(List<BluetoothDevice> devices) {
    _scannedDevices = devices;
  }

  void setBatteryLevel(int? level) {
    _batteryLevel = level;
  }

  // Test helper methods
  void setScanToThrowError(bool throwError) {
    _scanToThrowError = throwError;
  }

  void setConnectionCheckToThrowError(bool throwError) {
    _connectionCheckToThrowError = throwError;
  }

  void setConnectSuccess(bool success) {
    _connectSuccess = success;
  }

  void setDisconnectSuccess(bool success) {
    _disconnectSuccess = success;
  }

  void setDisconnectToThrowError(bool throwError) {
    _disconnectToThrowError = throwError;
  }

  void setForceAudioRoutingToThrowError(bool throwError) {
    _forceAudioRoutingToThrowError = throwError;
  }

  // These methods are no longer needed as we're now handling via the channel
  // but we'll keep them for backward compatibility

  Future<bool> isBluetoothEnabled() async => _isBluetoothEnabled;

  Future<BluetoothDevice?> getConnectedDevice() async => _connectedDevice;

  Future<bool> isAudioDeviceConnected() async => _isAudioDeviceConnected;

  Future<BluetoothAudioType> getBluetoothAudioType() async => _audioType;

  Future<void> startScan() async {
    _isScanning = true;
  }

  Future<void> stopScan() async {
    _isScanning = false;
  }

  Future<List<BluetoothDevice>> getScannedDevices() async => _scannedDevices;

  Future<int?> getBatteryLevel() async => _batteryLevel;

  Future<void> forceAudioRoutingToBluetooth() async {}
}
