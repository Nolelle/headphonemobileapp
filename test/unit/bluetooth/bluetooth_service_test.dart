import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/bluetooth/services/bluetooth_service.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyBluetoothService Tests', () {
    late MyBluetoothService bluetoothService;
    late List<MethodCall> log;

    setUp(() {
      bluetoothService = MyBluetoothService();
      log = <MethodCall>[];

      // Set up a mock method channel to intercept platform calls
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.headphonemobileapp/bluetooth'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'isBluetoothEnabled':
              return true;
            case 'startScan':
              return null;
            case 'stopScan':
              return null;
            case 'getScannedDevices':
              return [
                {
                  'id': '00:11:22:33:44:55',
                  'name': 'Test Headphones',
                  'type': 'classic',
                  'audioType': 'classic',
                },
                {
                  'id': 'AA:BB:CC:DD:EE:FF',
                  'name': 'LE Audio Headphones',
                  'type': 'dual',
                  'audioType': 'le_audio',
                },
              ];
            case 'connectToDevice':
              return true;
            case 'disconnectDevice':
              return true;
            case 'getConnectedDevice':
              return {
                'id': '00:11:22:33:44:55',
                'name': 'Test Headphones',
                'type': 'classic',
                'audioType': 'classic',
              };
            case 'isAudioDeviceConnected':
              return true;
            case 'openBluetoothSettings':
              return null;
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

    test('isBluetoothEnabled should call platform method and return result',
        () async {
      // Act
      final result = await bluetoothService.isBluetoothEnabled();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'isBluetoothEnabled');
      expect(result, true);
    });

    test('startScan should call platform method', () async {
      // Act
      await bluetoothService.startScan();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'startScan');
    });

    test('stopScan should call platform method', () async {
      // Act
      await bluetoothService.stopScan();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'stopScan');
    });

    test('getScannedDevices should call platform method and return devices',
        () async {
      // Act
      final devices = await bluetoothService.getScannedDevices();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'getScannedDevices');
      expect(devices, hasLength(2));

      // Check first device
      expect(devices[0].id, '00:11:22:33:44:55');
      expect(devices[0].name, 'Test Headphones');
      expect(devices[0].type, BluetoothDeviceType.classic);
      expect(devices[0].audioType, BluetoothAudioType.classic);

      // Check second device
      expect(devices[1].id, 'AA:BB:CC:DD:EE:FF');
      expect(devices[1].name, 'LE Audio Headphones');
      expect(devices[1].type, BluetoothDeviceType.dual);
      expect(devices[1].audioType, BluetoothAudioType.leAudio);
    });

    test('connectToDevice should call platform method with device ID',
        () async {
      // Arrange
      const deviceId = '00:11:22:33:44:55';

      // Act
      final result = await bluetoothService.connectToDevice(deviceId);

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'connectToDevice');
      expect(log.first.arguments, {'deviceId': deviceId});
      expect(result, true);
    });

    test('disconnectDevice should call platform method', () async {
      // Act
      await bluetoothService.disconnectDevice();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'disconnectDevice');
    });

    test('openBluetoothSettings should call platform method', () async {
      // Act
      await bluetoothService.openBluetoothSettings();

      // Assert
      expect(log, hasLength(1));
      expect(log.first.method, 'openBluetoothSettings');
    });

    test('should handle platform exceptions gracefully', () async {
      // Set up a mock method channel that throws exceptions
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.headphonemobileapp/bluetooth'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          throw PlatformException(code: 'TEST_ERROR', message: 'Test error');
        },
      );

      // Act & Assert - these should not throw exceptions
      expect(await bluetoothService.isBluetoothEnabled(), false);

      await bluetoothService.openBluetoothSettings(); // Should not throw

      expect(await bluetoothService.getScannedDevices(), isEmpty);

      // stopScan catches exceptions and doesn't rethrow
      await bluetoothService.stopScan(); // Should not throw

      // These should throw exceptions
      expect(() => bluetoothService.startScan(),
          throwsA(isA<PlatformException>()));
      expect(() => bluetoothService.connectToDevice('test'),
          throwsA(isA<PlatformException>()));
      expect(() => bluetoothService.disconnectDevice(),
          throwsA(isA<PlatformException>()));
    });
  });
}
