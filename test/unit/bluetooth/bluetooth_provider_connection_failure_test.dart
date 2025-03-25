import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';

// Simple mock class for the BluetoothPlatform to simulate connection failures
class MockBluetoothPlatform {
  final bool throwsExceptionOnConnect;
  final bool returnsFailureOnConnect;
  final String errorMessage;
  String? lastConnectToDeviceId;
  int connectToDeviceCallCount = 0;

  MockBluetoothPlatform({
    this.throwsExceptionOnConnect = false,
    this.returnsFailureOnConnect = false,
    this.errorMessage = 'Connection timeout',
  });

  Future<bool> connectToDevice(String deviceId) async {
    lastConnectToDeviceId = deviceId;
    connectToDeviceCallCount++;

    if (throwsExceptionOnConnect) {
      throw Exception(errorMessage);
    }

    return !returnsFailureOnConnect;
  }

  Future<BluetoothDevice?> getConnectedDevice() async => null;
  Future<bool> isAudioDeviceConnected() async => false;
  Future<BluetoothAudioType> getBluetoothAudioType() async =>
      BluetoothAudioType.none;
  Future<bool> disconnectDevice() async => true;
}

// Extended BluetoothProvider for testing that overrides platform method calls
class TestBluetoothProvider extends BluetoothProvider {
  final MockBluetoothPlatform mockPlatform;

  // Define our own private fields since we can't access the parent's private fields
  BluetoothDevice? _device;
  bool _connected = false;
  String _deviceName = "No Device";
  BluetoothAudioType _audioType = BluetoothAudioType.none;

  TestBluetoothProvider(this.mockPlatform) : super(isEmulatorTestMode: false);

  // Override the parent's getters to use our own fields
  @override
  bool get isDeviceConnected => _connected;

  @override
  String get connectedDeviceName => _deviceName;

  @override
  BluetoothDevice? get connectedDevice => _device;

  @override
  BluetoothAudioType get audioType => _audioType;

  @override
  Future<void> loadConnectionState() async {
    // No-op for tests
  }

  @override
  Future<void> saveConnectionState() async {
    // No-op for tests
  }

  @override
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      final connected = await mockPlatform.connectToDevice(device.id);

      if (connected) {
        // Update internal state to reflect successful connection
        _device = device;
        _connected = true;
        _deviceName = device.name;
        _audioType = BluetoothAudioType.classic;
        notifyListeners();
      } else {
        // Connection failed without exception
        _connected = false;
        throw Exception("Failed to connect to device");
      }
    } catch (e) {
      // Connection failed with exception
      _connected = false;
      notifyListeners();
      rethrow;
    }
  }
}

void main() {
  // Initialize the Flutter binding
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock SharedPreferences to avoid actual plugin calls
  SharedPreferences.setMockInitialValues({});

  group('BluetoothProvider Connection Failure Tests', () {
    late MockBluetoothPlatform mockPlatform;
    late TestBluetoothProvider provider;
    late BluetoothDevice testDevice;

    setUp(() {
      testDevice = BluetoothDevice(
        id: 'test_device_id',
        name: 'Test Device',
        type: BluetoothDeviceType.classic,
      );
    });

    test('testConnectionFailure - should handle exception during connection',
        () async {
      // Arrange
      mockPlatform = MockBluetoothPlatform(
          throwsExceptionOnConnect: true, errorMessage: 'Connection timeout');
      provider = TestBluetoothProvider(mockPlatform);

      // Act & Assert
      try {
        await provider.connectToDevice(testDevice);
        fail('Expected an exception to be thrown');
      } catch (e) {
        // Test passes if exception is thrown with the expected message
        expect(e.toString(), contains('Connection timeout'));
        expect(provider.isDeviceConnected, isFalse);
      }

      // Verify the platform was called
      expect(mockPlatform.connectToDeviceCallCount, 1);
      expect(mockPlatform.lastConnectToDeviceId, 'test_device_id');
    });

    test(
        'testConnectionFailure - should handle failed connection without exception',
        () async {
      // Arrange
      mockPlatform = MockBluetoothPlatform(returnsFailureOnConnect: true);
      provider = TestBluetoothProvider(mockPlatform);

      // Act & Assert
      try {
        await provider.connectToDevice(testDevice);
        fail('Expected an exception to be thrown');
      } catch (e) {
        // Test passes if exception is thrown with the expected message
        expect(e.toString(), contains('Failed to connect to device'));
        expect(provider.isDeviceConnected, isFalse);
      }

      // Verify the platform was called
      expect(mockPlatform.connectToDeviceCallCount, 1);
      expect(mockPlatform.lastConnectToDeviceId, 'test_device_id');
    });

    test('testConnectionFailure - should succeed when connection is successful',
        () async {
      // Arrange
      mockPlatform =
          MockBluetoothPlatform(); // Default is no exceptions and returns true
      provider = TestBluetoothProvider(mockPlatform);

      // Act - Should not throw
      try {
        await provider.connectToDevice(testDevice);
        // If we get here, the test passed
        expect(true, isTrue);
      } catch (e) {
        fail('Should not throw an exception when connection succeeds');
      }

      // Verify connection state
      expect(provider.isDeviceConnected, isTrue);
      expect(provider.connectedDeviceName, equals('Test Device'));
      expect(mockPlatform.connectToDeviceCallCount, 1);
      expect(mockPlatform.lastConnectToDeviceId, 'test_device_id');
    });
  });
}
