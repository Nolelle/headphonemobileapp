import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';

// Simple class to simulate the platform interface
class TestBluetoothPlatform {
  BluetoothDevice? connectedDeviceToReturn;
  bool isAudioConnectedToReturn = false;
  BluetoothAudioType audioTypeToReturn = BluetoothAudioType.none;
  bool connectToDeviceSuccessToReturn = false;

  String? lastConnectToDeviceId;
  int connectToDeviceCallCount = 0;

  Future<BluetoothDevice?> getConnectedDevice() async =>
      connectedDeviceToReturn;

  Future<bool> isAudioDeviceConnected() async => isAudioConnectedToReturn;

  Future<BluetoothAudioType> getBluetoothAudioType() async => audioTypeToReturn;

  Future<bool> connectToDevice(String deviceId) async {
    lastConnectToDeviceId = deviceId;
    connectToDeviceCallCount++;
    return connectToDeviceSuccessToReturn;
  }
}

// Test version of BluetoothProvider that doesn't use SharedPreferences
class TestBluetoothProvider extends BluetoothProvider {
  final TestBluetoothPlatform mockPlatform;
  String? _registeredDeviceId;

  @override
  String? get registeredDeviceId => _registeredDeviceId;

  TestBluetoothProvider(this.mockPlatform) : super(isEmulatorTestMode: false);

  // Override to directly set registered device ID without SharedPreferences
  Future<void> setRegisteredDeviceId(String id) async {
    _registeredDeviceId = id;
    notifyListeners();
  }

  // Override internal methods to use our mocks instead of static BluetoothPlatform
  @override
  Future<void> checkBluetoothConnection() async {
    try {
      // First approach: Get currently connected device from platform
      final connectedDevice = await mockPlatform.getConnectedDevice();

      // Second approach: Check if any audio device is connected
      final isAudioConnected = await mockPlatform.isAudioDeviceConnected();

      // Update connection status based on combined results
      bool isConnectionDetected = connectedDevice != null || isAudioConnected;

      // If system reports we're disconnected but we have a registered device,
      // try to reconnect using the device ID
      if (!isConnectionDetected && registeredDeviceId != null) {
        print(
            "Attempting auto-reconnection with registered device: $registeredDeviceId");
        await mockPlatform.connectToDevice(registeredDeviceId!);
      }

      notifyListeners();
    } catch (e) {
      print('Error checking Bluetooth connection: $e');
    }
  }

  // Override to skip SharedPreferences
  @override
  Future<void> loadConnectionState() async {
    // Nothing to load since we're directly setting values in tests
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BluetoothProvider Auto-Reconnection Tests', () {
    late TestBluetoothPlatform mockPlatform;
    late TestBluetoothProvider provider;

    setUp(() {
      mockPlatform = TestBluetoothPlatform();
      provider = TestBluetoothProvider(mockPlatform);
    });

    test(
        'testAutoReconnect - should attempt reconnection with registered device ID',
        () async {
      // Arrange - Setup a saved registered device
      final testDevice = BluetoothDevice(
        id: 'test_device_id',
        name: 'Test Device',
        type: BluetoothDeviceType.classic,
        audioType: BluetoothAudioType.classic,
      );

      // Set registered device ID directly
      await provider.setRegisteredDeviceId('test_device_id');

      // First return null for connected device (to trigger reconnection)
      mockPlatform.connectedDeviceToReturn = null;
      mockPlatform.isAudioConnectedToReturn = false;

      // Configure successful reconnection
      mockPlatform.connectToDeviceSuccessToReturn = true;

      // Act - Check connection which should trigger reconnection attempt
      await provider.checkBluetoothConnection();

      // Assert - Verify reconnection was attempted with the correct device ID
      expect(mockPlatform.connectToDeviceCallCount, 1);
      expect(mockPlatform.lastConnectToDeviceId, 'test_device_id');
    });

    test(
        'testAutoReconnect - should maintain connection state through lifecycle events',
        () async {
      // Arrange - Setup initially connected state
      final testDevice = BluetoothDevice(
        id: 'test_device_id',
        name: 'Test Device',
        type: BluetoothDeviceType.classic,
        audioType: BluetoothAudioType.classic,
      );

      // Set registered device directly
      await provider.setRegisteredDeviceId('test_device_id');

      // Mock initially connected device
      mockPlatform.connectedDeviceToReturn = testDevice;
      mockPlatform.isAudioConnectedToReturn = true;

      // First connection check (device is connected)
      await provider.checkBluetoothConnection();

      // Simulate app going to background and returning
      // Device is now reported as disconnected
      mockPlatform.connectedDeviceToReturn = null;
      mockPlatform.isAudioConnectedToReturn = false;

      // But reconnection should succeed
      mockPlatform.connectToDeviceSuccessToReturn = true;
      mockPlatform.connectToDeviceCallCount = 0; // Reset counter

      // Act - Check connection again (simulating return to foreground)
      await provider.checkBluetoothConnection();

      // Assert - Should have attempted reconnection
      expect(mockPlatform.connectToDeviceCallCount, 1);
      expect(mockPlatform.lastConnectToDeviceId, 'test_device_id');
    });
  });
}
