import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BluetoothPlatform Scan Tests', () {
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.headphonemobileapp/bluetooth'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);

          switch (methodCall.method) {
            case 'startScan':
              return null;
            case 'getScannedDevices':
              return [
                {
                  'id': 'device1',
                  'name': 'Device 1',
                  'type': 'classic',
                },
                {
                  'id': 'device2',
                  'name': 'Device 2',
                  'type': 'le',
                  'audioType': 'le_audio',
                }
              ];
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.headphonemobileapp/bluetooth'), null);
    });

    test('startScan should call platform method', () async {
      // Act
      await BluetoothPlatform.startScan();

      // Assert
      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, 'startScan');
    });

    test('getScannedDevices should return properly parsed device objects',
        () async {
      // Act
      final devices = await BluetoothPlatform.getScannedDevices();

      // Assert
      expect(devices, hasLength(2));

      // Check first device
      expect(devices[0].id, 'device1');
      expect(devices[0].name, 'Device 1');
      expect(devices[0].type, BluetoothDeviceType.classic);
      expect(devices[0].audioType, null);

      // Check second device
      expect(devices[1].id, 'device2');
      expect(devices[1].name, 'Device 2');
      expect(devices[1].type, BluetoothDeviceType.le);
      expect(devices[1].audioType, BluetoothAudioType.leAudio);
    });

    test('startScan and getScannedDevices sequence works correctly', () async {
      // Act
      await BluetoothPlatform.startScan();
      final devices = await BluetoothPlatform.getScannedDevices();

      // Assert
      expect(methodCalls, hasLength(2));
      expect(methodCalls[0].method, 'startScan');
      expect(methodCalls[1].method, 'getScannedDevices');

      expect(devices, hasLength(2));
      expect(devices[0].name, 'Device 1');
      expect(devices[1].name, 'Device 2');
    });

    test('startScan handles exceptions correctly', () async {
      // Override mock handler to throw exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.headphonemobileapp/bluetooth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'startScan') {
            throw PlatformException(
              code: 'SCAN_ERROR',
              message: 'Failed to start scan',
            );
          }
          return null;
        },
      );

      // Act & Assert
      expect(() => BluetoothPlatform.startScan(),
          throwsA(isA<PlatformException>()));
    });
  });
}
