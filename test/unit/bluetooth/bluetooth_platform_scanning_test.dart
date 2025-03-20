import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BluetoothPlatform Scanning Tests', () {
    // Setup mock method channel to intercept calls to the platform
    const MethodChannel channel =
        MethodChannel('com.headphonemobileapp/bluetooth');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      // Set up mock handler for the platform channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);

        // Return appropriate mock values for each method
        switch (methodCall.method) {
          case 'startScan':
            return null;
          case 'getScannedDevices':
            return [
              {
                'id': 'device1',
                'name': 'Device 1',
                'type': 'classic',
                'audioType': 'classic'
              },
              {
                'id': 'device2',
                'name': 'Device 2',
                'type': 'le',
                'audioType': 'le_audio'
              },
            ];
          case 'stopScan':
            return null;
          default:
            return null;
        }
      });

      // Clear the log before each test
      log.clear();
    });

    tearDown(() {
      // Clear mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('testStartScan - should invoke startScan method on platform channel',
        () async {
      // Act
      await BluetoothPlatform.startScan();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'startScan');
    });

    test('testGetScannedDevices - should retrieve and parse devices correctly',
        () async {
      // Act
      final devices = await BluetoothPlatform.getScannedDevices();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'getScannedDevices');

      // Verify device parsing
      expect(devices.length, 2);

      // Check first device
      expect(devices[0].id, 'device1');
      expect(devices[0].name, 'Device 1');
      expect(devices[0].type, BluetoothDeviceType.classic);
      expect(devices[0].audioType, BluetoothAudioType.classic);

      // Check second device
      expect(devices[1].id, 'device2');
      expect(devices[1].name, 'Device 2');
      expect(devices[1].type, BluetoothDeviceType.le);
      expect(devices[1].audioType, BluetoothAudioType.leAudio);
    });

    test('testStopScan - should invoke stopScan method on platform channel',
        () async {
      // Act
      await BluetoothPlatform.stopScan();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'stopScan');
    });

    test('testStartScan - should handle platform exceptions gracefully',
        () async {
      // Setup error case
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        throw PlatformException(code: 'TEST_ERROR', message: 'Test error');
      });

      // Act & Assert
      expect(() => BluetoothPlatform.startScan(),
          throwsA(isA<PlatformException>()));
      expect(log, hasLength(1));
      expect(log.first.method, 'startScan');
    });

    test(
        'testGetScannedDevices - should return empty list on platform exception',
        () async {
      // Setup error case
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        throw PlatformException(code: 'TEST_ERROR', message: 'Test error');
      });

      // Act
      final devices = await BluetoothPlatform.getScannedDevices();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'getScannedDevices');
      expect(devices, isEmpty);
    });
  });
}
