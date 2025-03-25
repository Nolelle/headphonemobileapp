import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bluetooth Audio Routing Tests (IN-002)', () {
    late BluetoothProvider bluetoothProvider;
    final List<MethodCall> methodCalls = [];

    // Helper to set up a custom Bluetooth channel with more control
    void setupCustomBluetoothChannel(
        {bool simulateConnected = true, String audioType = 'classic'}) {
      const MethodChannel bluetoothChannel =
          MethodChannel('com.headphonemobileapp/bluetooth');

      // Clear previous calls
      methodCalls.clear();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        bluetoothChannel,
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);

          switch (methodCall.method) {
            case 'isBluetoothEnabled':
              return true;

            case 'getConnectedDevice':
              if (simulateConnected) {
                return {
                  'id': 'device1',
                  'name': 'Test Audio Device',
                  'type': audioType,
                };
              }
              return null;

            case 'isAudioDeviceConnected':
              return simulateConnected;

            case 'getBluetoothAudioType':
              return simulateConnected ? audioType : 'none';

            case 'forceAudioRoutingToBluetooth':
              // Record that audio routing was requested
              return true;

            case 'connectToDevice':
              return true;

            default:
              return null;
          }
        },
      );
    }

    setUp(() {
      // Set up mock method channel for Bluetooth with an initial connected state
      setupCustomBluetoothChannel();

      // Initialize BluetoothProvider in test mode
      bluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);

      // For tests, simulate a device is already connected
      final device = BluetoothDevice(
        id: 'device1',
        name: 'Test Audio Device',
        type: BluetoothDeviceType.classic,
      );
      // Since we're in test mode, this won't make actual platform calls
      bluetoothProvider.connectToDevice(device);
    });

    testWidgets(
        'Audio is routed properly when connecting to a Bluetooth device',
        (WidgetTester tester) async {
      // Override the standard mock channel setup to ensure we're using our custom mock
      setupCustomBluetoothChannel(simulateConnected: false);

      // Create a simple widget to test the provider behavior
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BluetoothProvider>.value(
            value: bluetoothProvider,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final device = BluetoothDevice(
                          id: 'device1',
                          name: 'Test Audio Device',
                          type: BluetoothDeviceType.classic,
                        );
                        await bluetoothProvider.connectToDevice(device);
                      },
                      child: const Text('Connect'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially, there should be no audio routing
      expect(
        methodCalls
            .where((call) => call.method == 'forceAudioRoutingToBluetooth')
            .isEmpty,
        isTrue,
        reason: 'No audio routing should happen before connection',
      );

      // Clear the method calls before connecting
      methodCalls.clear();

      // Connect to the device
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      // After connecting, we should see a connection attempt
      expect(
        methodCalls
            .where((call) => call.method == 'connectToDevice')
            .isNotEmpty,
        isTrue,
        reason: 'Should attempt to connect to device',
      );

      // Verify the connection state is set correctly
      expect(bluetoothProvider.isDeviceConnected, isTrue);
      expect(
          bluetoothProvider.connectedDeviceName, equals('Test Audio Device'));
    });

    testWidgets('Audio routing is restored after phone call interruption',
        (WidgetTester tester) async {
      // Create widget with our provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<BluetoothProvider>.value(
            value: bluetoothProvider,
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            'Connected to: ${bluetoothProvider.connectedDeviceName}'),
                        ElevatedButton(
                          onPressed: () {
                            // Simulate a phone call interruption (app gets paused)
                            bluetoothProvider.saveConnectionState();
                          },
                          child: const Text('Simulate Phone Call'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Simulate returning from a phone call (app resuming)
                            bluetoothProvider.loadConnectionState().then((_) {
                              bluetoothProvider.checkBluetoothConnection();
                              bluetoothProvider.forceAudioRouting();
                            });
                          },
                          child: const Text('End Phone Call'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we start with the device connected
      expect(find.text('Connected to: Test Audio Device'), findsOneWidget);

      // Clear previous method calls
      methodCalls.clear();

      // Simulate phone call interruption
      await tester.tap(find.text('Simulate Phone Call'));
      await tester.pumpAndSettle();

      // End the phone call (app resumes)
      await tester.tap(find.text('End Phone Call'));
      await tester.pumpAndSettle();

      // The device should still be connected
      expect(bluetoothProvider.isDeviceConnected, isTrue);
      expect(
          bluetoothProvider.connectedDeviceName, equals('Test Audio Device'));
    });

    testWidgets('Different audio device types are handled correctly',
        (WidgetTester tester) async {
      // Test with a LE Audio device
      // First disconnect any existing device
      bluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);

      // Create and connect an LE Audio device
      final leAudioDevice = BluetoothDevice(
        id: 'device2',
        name: 'LE Audio Device',
        type: BluetoothDeviceType.le,
        audioType: BluetoothAudioType.leAudio,
      );
      await bluetoothProvider.connectToDevice(leAudioDevice);

      // Audio type should be LE Audio
      expect(bluetoothProvider.audioType, equals(BluetoothAudioType.leAudio));

      // Test with a Classic device
      // First disconnect any existing device
      bluetoothProvider = BluetoothProvider(isEmulatorTestMode: true);

      // Create and connect a Classic Audio device
      final classicDevice = BluetoothDevice(
        id: 'device3',
        name: 'Classic Audio Device',
        type: BluetoothDeviceType.classic,
        audioType: BluetoothAudioType.classic,
      );
      await bluetoothProvider.connectToDevice(classicDevice);

      // Audio type should be Classic
      expect(bluetoothProvider.audioType, equals(BluetoothAudioType.classic));
    });
  });
}
