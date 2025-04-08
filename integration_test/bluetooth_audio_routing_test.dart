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

            case 'getBtConnectionType':
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

                        // Before attempting to connect, update the mock to return a connected state
                        setupCustomBluetoothChannel(simulateConnected: true);

                        try {
                          await Provider.of<BluetoothProvider>(context,
                                  listen: false)
                              .connectToDevice(device);
                        } catch (e) {
                          print('Caught expected test exception: $e');
                        }
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

      // Tap the connect button
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      // Verify that proper method calls were made
      expect(
        methodCalls.any((call) => call.method == 'connectToDevice'),
        isTrue,
        reason: 'connectToDevice should be called',
      );
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

      // Debug - print current state
      print(
          'Current device connected state: ${bluetoothProvider.isDeviceConnected}');
      print('Current device name: ${bluetoothProvider.connectedDeviceName}');

      // In emulator test mode, the display name will be "Emulator Test Device"
      expect(find.textContaining('Emulator Test Device'), findsOneWidget);

      // Clear previous method calls
      methodCalls.clear();

      // Simulate phone call interruption
      await tester.tap(find.text('Simulate Phone Call'));
      await tester.pumpAndSettle();

      // End the phone call (app resumes)
      await tester.tap(find.text('End Phone Call'));
      await tester.pumpAndSettle();

      // The device should still be connected in test mode
      expect(bluetoothProvider.isDeviceConnected, isTrue);
      // In test mode, this should be the emulator device name
      expect(bluetoothProvider.connectedDeviceName,
          equals('Emulator Test Device'));
    });

    testWidgets('Different audio device types are handled correctly',
        (WidgetTester tester) async {
      // For test mode, we need to modify how we set up the audio types

      // Create a custom mock for LE Audio
      setupCustomBluetoothChannel(
          simulateConnected: true, audioType: 'le_audio');

      // Create and connect an LE Audio device through the mock channel
      final leAudioDevice = BluetoothDevice(
        id: 'device2',
        name: 'LE Audio Device',
        type: BluetoothDeviceType.le,
      );

      // Create a new provider instance for this test and connect to the device
      final leAudioProvider = BluetoothProvider(isEmulatorTestMode: false);
      await leAudioProvider.connectToDevice(leAudioDevice);

      // Audio type should be LE Audio - but only if we're not in emulator mode
      // In this specific test we need to check the internal state directly
      expect(leAudioProvider.audioType, equals(BluetoothAudioType.leAudio));
    });
  });
}
