import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';
import 'package:projects/features/bluetooth/services/ble_data_service.dart';
import 'package:projects/features/presets/models/preset.dart';

// Mock class for BLE Data method channel with more detailed retry tracking
class ReconnectingMockBleMethodChannel {
  final List<int> failOnChunkIndices;
  final int reconnectAfterAttempts;
  final int reconnectDelayMs;
  final bool autoReconnect;
  final bool shouldFailGattReady;
  final int gattReadyAfterAttempts;

  // Connection state tracking
  bool isConnected = true;
  List<int> sentChunks = [];
  List<int> retryAttempts = [];
  Map<int, int> chunkRetryCount = {};
  int connectionLossCount = 0;
  int reconnectionCount = 0;
  int writeAttempts = 0;
  bool gattReady = true;
  List<String> eventLog = [];

  ReconnectingMockBleMethodChannel({
    required this.failOnChunkIndices,
    this.reconnectAfterAttempts = 1,
    this.reconnectDelayMs = 100,
    this.autoReconnect = true,
    this.shouldFailGattReady = false,
    this.gattReadyAfterAttempts = 1,
  });

  void logEvent(String event) {
    eventLog.add("${DateTime.now()}: $event");
    print(event); // Add this line to log to console for debugging
  }

  Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'writeCharacteristic':
        writeAttempts++;
        final data = methodCall.arguments['data'] as Uint8List;
        final int chunkIndex = data.isNotEmpty ? data[0] : -1;
        final bool withoutResponse =
            methodCall.arguments['withoutResponse'] as bool;

        logEvent(
            "Attempt to write chunk $chunkIndex (withoutResponse: $withoutResponse)");

        // Can't write if not connected or GATT not ready
        if (!isConnected || !gattReady) {
          logEvent(
              "Write failed: isConnected=$isConnected, gattReady=$gattReady");
          return false;
        }

        // Check if this chunk should fail
        if (failOnChunkIndices.contains(chunkIndex)) {
          // Track retry attempts for this chunk
          chunkRetryCount[chunkIndex] = (chunkRetryCount[chunkIndex] ?? 0) + 1;
          retryAttempts.add(chunkIndex);

          // If we've tried this chunk enough times, simulate connection loss
          if (chunkRetryCount[chunkIndex]! >= reconnectAfterAttempts) {
            // Simulate connection loss
            logEvent("Simulating connection loss on chunk $chunkIndex");
            isConnected = false;
            connectionLossCount++;
            gattReady = false;

            if (autoReconnect) {
              // Auto-reconnect after delay
              await Future.delayed(Duration(milliseconds: reconnectDelayMs));
              isConnected = true;
              reconnectionCount++;
              logEvent(
                  "Simulating reconnection after loss on chunk $chunkIndex");

              // GATT takes a moment to become ready after reconnection
              if (!shouldFailGattReady ||
                  gattReadyAfterAttempts <= reconnectionCount) {
                await Future.delayed(Duration(milliseconds: 50));
                gattReady = true;
                logEvent("GATT services rediscovered after reconnection");

                // Now the chunk succeeds after reconnection
                sentChunks.add(chunkIndex);
                logEvent(
                    "Chunk $chunkIndex sent successfully after reconnection");
                return true;
              } else {
                logEvent("GATT services failed to be rediscovered");
                return false;
              }
            } else {
              // No auto-reconnect, stay disconnected
              logEvent("Connection lost permanently on chunk $chunkIndex");
              return false;
            }
          } else {
            // Not enough retry attempts yet, fail but stay connected
            logEvent(
                "Chunk $chunkIndex failed, retry attempt #${chunkRetryCount[chunkIndex]}");
            return false;
          }
        }

        // Normal success case
        sentChunks.add(chunkIndex);
        logEvent("Chunk $chunkIndex sent successfully");
        return true;

      case 'isGattReady':
        logEvent("Checking GATT ready status: $gattReady");
        return gattReady;

      case 'isAudioDeviceConnected':
        logEvent("Checking device connection status: $isConnected");
        return isConnected;

      default:
        return null;
    }
  }
}

// Mock implementation for Bluetooth Platform
class MockBluetoothPlatform {
  static bool mockConnected = true;
  static ReconnectingMockBleMethodChannel? mockedChannel;

  static Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    // If we have a mocked channel, use its connection state
    if (mockedChannel != null) {
      if (methodCall.method == 'isAudioDeviceConnected') {
        return mockedChannel!.isConnected;
      }
    } else {
      // Otherwise use our static value
      if (methodCall.method == 'isAudioDeviceConnected') {
        return mockConnected;
      }
    }
    return null;
  }

  static void setupMockBluetoothPlatform(
      ReconnectingMockBleMethodChannel? channel) {
    mockedChannel = channel;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('com.headphonemobileapp/bluetooth'),
            handleMethodCall);
  }

  static void resetMockBluetoothPlatform() {
    mockConnected = true;
    mockedChannel = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('com.headphonemobileapp/bluetooth'), null);
  }
}

// Large preset factory for testing
class TestDataFactory {
  static Preset createLargePreset() {
    final Map<String, dynamic> presetData = {
      'db_valueOV': 45.0,
      'db_valueSB_BS': 50.0,
      'db_valueSB_MRS': 30.0,
      'db_valueSB_TS': 25.0,
      'reduce_background_noise': true,
      'reduce_wind_noise': true,
      'soften_sudden_noise': false,
      // Add large data to ensure chunking
      'largeData': List.generate(2000, (i) => 'data_$i').join(','),
    };

    return Preset(
      id: 'test_large_preset',
      name: 'Test Large Preset',
      dateCreated: DateTime.now(),
      presetData: presetData,
    );
  }

  static Preset createSmallPreset() {
    final Map<String, dynamic> presetData = {
      'db_valueOV': 45.0,
      'db_valueSB_BS': 50.0,
      'db_valueSB_MRS': 30.0,
      'db_valueSB_TS': 25.0,
      'reduce_background_noise': true,
      'reduce_wind_noise': false,
      'soften_sudden_noise': true,
    };

    return Preset(
      id: 'test_small_preset',
      name: 'Test Small Preset',
      dateCreated: DateTime.now(),
      presetData: presetData,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BLE Data Transfer Retry Mechanism Tests', () {
    // Setup before each test
    late ReconnectingMockBleMethodChannel mockBleChannel;
    late Preset largePreset;
    late Preset smallPreset;

    setUp(() {
      largePreset = TestDataFactory.createLargePreset();
      smallPreset = TestDataFactory.createSmallPreset();
      MockBluetoothPlatform.setupMockBluetoothPlatform(null);
      MockBluetoothPlatform.mockConnected = true;
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.headphonemobileapp/ble_data'), null);
      MockBluetoothPlatform.resetMockBluetoothPlatform();
    });

    // Helper to setup the mock and execute test
    Future<bool> performTransferTest(
        ReconnectingMockBleMethodChannel mockChannel, Preset preset) async {
      // Setup method channel mock for BLE data
      final methodChannel =
          const MethodChannel('com.headphonemobileapp/ble_data');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              methodChannel, mockChannel.handleMethodCall);

      // Also update the Bluetooth platform mock to use our mock channel
      MockBluetoothPlatform.setupMockBluetoothPlatform(mockChannel);

      // Create service
      final bleDataService = BLEDataService();

      // Perform the actual data transfer
      return await bleDataService.sendPresetData(preset);
    }

    // Complete test suite for retry mechanism
    test('should recover after connection loss', () async {
      // Create mock that will fail and recover
      mockBleChannel = ReconnectingMockBleMethodChannel(
        failOnChunkIndices: [123], // Target the actual chunk index used
        reconnectAfterAttempts: 1, // Fail after first attempt
        autoReconnect: true,
      );

      // Perform test
      final result = await performTransferTest(mockBleChannel, smallPreset);

      // Verify expectations
      expect(result, isTrue, reason: 'Transfer should succeed with retry');
      expect(mockBleChannel.connectionLossCount, equals(1),
          reason: 'Should have one connection loss');
      expect(mockBleChannel.reconnectionCount, equals(1),
          reason: 'Should have one reconnection');
      expect(mockBleChannel.sentChunks, contains(123),
          reason: 'Chunk should be sent successfully after retry');
    });

    test('should fail if no auto-reconnect and connection lost', () async {
      // Create mock that will fail without reconnection
      mockBleChannel = ReconnectingMockBleMethodChannel(
        failOnChunkIndices: [123], // Target the actual chunk index used
        reconnectAfterAttempts: 1,
        autoReconnect: false, // No auto-reconnect
      );

      // Perform test
      final result = await performTransferTest(mockBleChannel, smallPreset);

      // Verify expectations
      expect(result, isFalse,
          reason: 'Transfer should fail without reconnection');
      expect(mockBleChannel.connectionLossCount, equals(1),
          reason: 'Should have one connection loss');
      expect(mockBleChannel.reconnectionCount, equals(0),
          reason: 'Should have no reconnection attempts');
    });

    test('should fail if GATT service discovery fails after reconnection',
        () async {
      // Create mock that will reconnect but fail GATT discovery
      mockBleChannel = ReconnectingMockBleMethodChannel(
        failOnChunkIndices: [123],
        reconnectAfterAttempts: 1,
        autoReconnect: true,
        shouldFailGattReady: true, // Fail GATT rediscovery
        gattReadyAfterAttempts: 2, // Require more reconnects than will happen
      );

      // Perform test
      final result = await performTransferTest(mockBleChannel, smallPreset);

      // Verify expectations
      expect(result, isFalse,
          reason: 'Transfer should fail when GATT rediscovery fails');
      expect(mockBleChannel.connectionLossCount, equals(1),
          reason: 'Should have one connection loss');
      expect(mockBleChannel.reconnectionCount, equals(1),
          reason: 'Should have one reconnection attempt');
      expect(
          mockBleChannel.eventLog
              .any((event) => event.contains('GATT services failed')),
          isTrue,
          reason: 'Should log GATT service discovery failure');
    });

    test('should retry multiple times before succeeding', () async {
      // Create mock that requires multiple retries
      mockBleChannel = ReconnectingMockBleMethodChannel(
        failOnChunkIndices: [123],
        reconnectAfterAttempts: 3, // Require 3 retries before reconnecting
        autoReconnect: true,
      );

      // Perform test
      final result = await performTransferTest(mockBleChannel, smallPreset);

      // Verify expectations
      expect(result, isTrue,
          reason: 'Transfer should succeed after multiple retries');
      expect(mockBleChannel.chunkRetryCount[123], equals(3),
          reason: 'Should retry the chunk 3 times');
      expect(mockBleChannel.connectionLossCount, equals(1),
          reason: 'Should have one connection loss');
      expect(mockBleChannel.reconnectionCount, equals(1),
          reason: 'Should have one reconnection');
    });
  });
}
