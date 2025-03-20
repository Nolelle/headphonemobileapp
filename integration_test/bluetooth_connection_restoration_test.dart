import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bluetooth Connection Restoration Tests (BT-007)', () {
    late BluetoothProvider bluetoothProvider;
    late Map<String, Object> sharedPrefsData;

    // Helper to set up a custom Bluetooth channel with more control
    void setupCustomBluetoothChannel() {
      const MethodChannel bluetoothChannel =
          MethodChannel('com.headphonemobileapp/bluetooth');

      // Store method call history to verify calls
      final List<MethodCall> methodCalls = [];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        bluetoothChannel,
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);

          switch (methodCall.method) {
            case 'isBluetoothEnabled':
              return true;

            case 'getConnectedDevice':
              return {
                'id': 'device1',
                'name': 'Test Device',
                'type': 'classic',
              };

            case 'isAudioDeviceConnected':
              return true;

            case 'getBluetoothAudioType':
              return 'classic';

            default:
              return null;
          }
        },
      );
    }

    setUp(() async {
      // Initialize shared preferences with a "connected" state
      sharedPrefsData = {
        'bluetooth_connected_device_id': 'device1',
        'bluetooth_connected_device_name': 'Test Device',
        'bluetooth_device_type': 'classic',
        'bluetooth_is_connected': 'true',
      };

      SharedPreferences.setMockInitialValues(sharedPrefsData);

      // Set up mock method channel for Bluetooth
      setupCustomBluetoothChannel();
    });

    testWidgets('Bluetooth connection state is maintained through app restart',
        (WidgetTester tester) async {
      // Create the Bluetooth provider with pre-set connection state
      bluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);

      // Initially, the provider shouldn't know about the connection
      expect(bluetoothProvider.isDeviceConnected, isFalse);

      // Load connection state (simulates app startup)
      await bluetoothProvider.loadConnectionState();

      // After loading, the provider should be connected based on saved preferences
      expect(bluetoothProvider.isDeviceConnected, isTrue);
      expect(bluetoothProvider.connectedDeviceName, equals('Test Device'));

      // Verify the connection with the platform
      await bluetoothProvider.checkBluetoothConnection();

      // After checking with platform, connection should still be maintained
      expect(bluetoothProvider.isDeviceConnected, isTrue);
      expect(bluetoothProvider.connectedDeviceName, equals('Test Device'));

      // Simulate app being paused
      await bluetoothProvider.saveConnectionState();

      // Create a new provider (simulates app restart)
      final newBluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);

      // Initially, new provider shouldn't know about connection
      expect(newBluetoothProvider.isDeviceConnected, isFalse);

      // Load connection state
      await newBluetoothProvider.loadConnectionState();

      // After loading, should be connected again
      expect(newBluetoothProvider.isDeviceConnected, isTrue);
      expect(newBluetoothProvider.connectedDeviceName, equals('Test Device'));
    });

    testWidgets('Bluetooth connection is restored when app launches',
        (WidgetTester tester) async {
      // Create a widget that will initialize the BluetoothProvider with savedState
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Create the provider
              bluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);

              // Delayed restore to simulate app startup logic
              Future.microtask(() async {
                await bluetoothProvider.loadConnectionState();
                await bluetoothProvider.checkBluetoothConnection();
              });

              return Scaffold(
                body: Consumer<BluetoothProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      children: [
                        Text(
                            'Connected: ${provider.isDeviceConnected ? 'Yes' : 'No'}'),
                        if (provider.isDeviceConnected)
                          Text('Device: ${provider.connectedDeviceName}'),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      // Initial state should show not connected
      expect(find.text('Connected: No'), findsOneWidget);

      // Pump a few frames to allow the Future.microtask to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Now we should see the connected state restored
      expect(find.text('Connected: Yes'), findsOneWidget);
      expect(find.text('Device: Test Device'), findsOneWidget);
    });
  });
}
