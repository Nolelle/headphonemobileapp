import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart';
import 'package:projects/features/bluetooth/services/ble_data_service.dart';
import 'package:projects/features/presets/models/preset.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';

// Mock class for BLE method channel that simulates partial data transfers
class PartialTransferMockChannel {
  // Control which chunks will successfully transfer
  final List<int> successfulChunks;
  final int totalChunks;
  final bool simulateDeviceRestart;
  final bool simulateNetworkLatency;
  final int networkLatencyMs;

  // Real data being tracked across chunks
  final List<int> receivedBytes = [];
  String partialJson = '';
  bool hasValidData = false;

  // Tracking variables
  final List<int> sentChunks = [];
  final List<int> failedChunks = [];
  bool transferComplete = false;
  bool deviceRestartOccurred = false;
  int transferAttempts = 0;

  // Logs for debugging
  List<String> logs = [];

  PartialTransferMockChannel({
    required this.successfulChunks,
    required this.totalChunks,
    this.simulateDeviceRestart = false,
    this.simulateNetworkLatency = true,
    this.networkLatencyMs = 100,
  });

  void log(String message) {
    logs.add("${DateTime.now()}: $message");
    print(message); // Print for test output
  }

  // Extract what data we can from partial bytes
  Map<String, dynamic> getReassembledData() {
    if (receivedBytes.isEmpty) return {};

    try {
      // Try to parse whatever bytes we have received so far
      String jsonStr = utf8.decode(receivedBytes);
      return jsonDecode(jsonStr);
    } catch (e) {
      // In case of parsing error, return any partial data we can
      if (partialJson.isNotEmpty) {
        try {
          // Try to add closing braces to make it valid JSON
          String fixedJson = '$partialJson}}';
          return jsonDecode(fixedJson);
        } catch (_) {}
      }
      log("Could not reassemble any valid data from partial transfer");
      return {};
    }
  }

  // Handle mock method calls
  Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'writeCharacteristic':
        // Extract data from the method call
        final data = methodCall.arguments['data'] as Uint8List;
        final characteristicUuid =
            methodCall.arguments['characteristicUuid'] as String;
        final withoutResponse = methodCall.arguments['withoutResponse'] as bool;

        transferAttempts++;

        // In the real implementation, the first byte is the chunk index
        // and the second byte is the total chunks - 1
        final int chunkIndex = data.isNotEmpty ? data[0] : -1;
        final int reportedTotalChunks = data.length > 1 ? data[1] + 1 : 0;

        // Simulate network latency
        if (simulateNetworkLatency) {
          await Future.delayed(Duration(milliseconds: networkLatencyMs));
        }

        log("Processing chunk $chunkIndex of $reportedTotalChunks for $characteristicUuid (withoutResponse: $withoutResponse)");

        // Check if this chunk should succeed according to our test config
        if (successfulChunks.contains(chunkIndex)) {
          // Process successful chunk
          sentChunks.add(chunkIndex);

          // Store received data (skip the first 2 bytes which are headers)
          if (data.length > 2) {
            // Collect bytes for reassembling later
            receivedBytes.addAll(data.sublist(2));

            // Try to build partial JSON string (for debugging)
            try {
              String chunk = utf8.decode(data.sublist(2));
              log("Received chunk data: ${chunk.substring(0, chunk.length > 20 ? 20 : chunk.length)}...");

              // Append to our partial JSON to try to get valid data
              partialJson += chunk;

              // If this appears to contain a full JSON object, mark data as valid
              if (partialJson.contains('{') && partialJson.contains('}')) {
                hasValidData = true;
              }
            } catch (e) {
              log("Error processing chunk data: $e");
            }
          }

          // Check if transfer is complete (all chunks received)
          if (sentChunks.length == totalChunks) {
            transferComplete = true;
            log("Transfer complete - all $totalChunks chunks received");
          }

          // Simulate device restart after some successful chunks if configured
          if (simulateDeviceRestart &&
              sentChunks.length > totalChunks / 2 &&
              !deviceRestartOccurred) {
            deviceRestartOccurred = true;
            log("Simulating device restart after partial transfer");

            // Return false to indicate failure at this point
            return false;
          }

          return true;
        } else {
          // Process failed chunk
          failedChunks.add(chunkIndex);
          log("Failed to send chunk $chunkIndex");
          return false;
        }

      case 'isGattReady':
        // If we've simulated a device restart, GATT isn't ready anymore
        if (deviceRestartOccurred) {
          log("GATT not ready after device restart");
          return false;
        }
        return true;

      case 'isReadyForTransmission':
        // If we've simulated a device restart, device isn't ready anymore
        if (deviceRestartOccurred) {
          log("Device not ready for transmission after restart");
          return false;
        }
        return true;

      default:
        log("Unhandled method: ${methodCall.method}");
        return null;
    }
  }
}

// Test data factory
class PartialTransferTestData {
  // Create preset with varying sizes
  static Preset createPreset({bool large = false}) {
    final Map<String, dynamic> presetData = {
      'db_valueOV': 45.0,
      'db_valueSB_BS': 50.0,
      'db_valueSB_MRS': 30.0,
      'db_valueSB_TS': 25.0,
      'reduce_background_noise': true,
      'reduce_wind_noise': true,
      'soften_sudden_noise': false,
    };

    // Add more data to create a large preset that will be chunked
    if (large) {
      presetData['largeData'] = List.generate(500, (i) => 'data_$i').join(',');
    }

    return Preset(
      id: 'test_preset_${large ? 'large' : 'small'}',
      name: 'Test ${large ? 'Large' : 'Small'} Preset',
      dateCreated: DateTime.now(),
      presetData: presetData,
    );
  }

  // Create sound test with varying sizes
  static SoundTest createSoundTest({bool large = false}) {
    final now = DateTime.now();

    // Create the sound test data - must be Map<String, double>
    final Map<String, double> soundTestData = {
      'L_user_250Hz_dB': 10.0,
      'R_user_250Hz_dB': 12.0,
      'L_user_500Hz_dB': 15.0,
      'R_user_500Hz_dB': 14.0,
      'L_user_1000Hz_dB': 20.0,
      'R_user_1000Hz_dB': 18.0,
      'L_user_2000Hz_dB': 25.0,
      'R_user_2000Hz_dB': 22.0,
      'L_user_4000Hz_dB': 30.0,
      'R_user_4000Hz_dB': 28.0,
    };

    // Add more data for large test
    if (large) {
      for (int i = 0; i < 100; i++) {
        // We need to keep the Map<String, double> type, so only add double values
        soundTestData['extra_data_$i'] = i.toDouble();
      }
    }

    return SoundTest(
      id: 'test_sound_test_${large ? 'large' : 'small'}',
      dateCreated: now,
      soundTestData: soundTestData,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Partial Data Transfer Tests', () {
    late BLEDataService bleDataService;

    setUp(() {
      bleDataService = BLEDataService();

      // Setup Bluetooth platform mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.headphonemobileapp/bluetooth'),
              (MethodCall methodCall) async {
        if (methodCall.method == 'isAudioDeviceConnected') {
          return true;
        }
        return null;
      });
    });

    tearDown(() {
      // Reset mock method channels
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.headphonemobileapp/ble_data'), null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.headphonemobileapp/bluetooth'), null);
    });

    // Helper method to setup mock and run a test
    Future<Map<String, dynamic>> runPartialTransferTest({
      required List<int> successfulChunks,
      required int totalChunks,
      bool simulateDeviceRestart = false,
      bool isPreset = true,
      bool isLarge = true,
    }) async {
      // Create the test data
      final testData = isPreset
          ? PartialTransferTestData.createPreset(large: isLarge)
          : PartialTransferTestData.createSoundTest(large: isLarge);

      // Setup the mock channel
      final mockChannel = PartialTransferMockChannel(
        successfulChunks: successfulChunks,
        totalChunks: totalChunks,
        simulateDeviceRestart: simulateDeviceRestart,
      );

      // Setup method channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.headphonemobileapp/ble_data'),
              mockChannel.handleMethodCall);

      // Perform the data transfer
      bool result;
      if (isPreset) {
        result = await bleDataService.sendPresetData(testData as Preset);
      } else {
        result =
            await bleDataService.sendHearingTestData(testData as SoundTest);
      }

      // Return test results
      return {
        'success': result,
        'sentChunks': mockChannel.sentChunks,
        'failedChunks': mockChannel.failedChunks,
        'transferComplete': mockChannel.transferComplete,
        'deviceRestartOccurred': mockChannel.deviceRestartOccurred,
        'transferAttempts': mockChannel.transferAttempts,
        'hasValidData': mockChannel.hasValidData,
        'receivedData': mockChannel.getReassembledData(),
        'logs': mockChannel.logs,
      };
    }

    test('should detect incomplete transfer when chunks are missing', () async {
      // Arrange: setup to transfer 5 chunks but only succeed with 3
      final result = await runPartialTransferTest(
        successfulChunks: [0, 1, 2], // Only first 3 chunks successful
        totalChunks: 5,
        isPreset: true,
        isLarge: true,
      );

      // Assert
      expect(result['success'], isFalse,
          reason: 'Transfer should fail when chunks are missing');
      expect(result['transferComplete'], isFalse,
          reason: 'Transfer should not be marked complete');
      expect((result['sentChunks'] as List).length, equals(3),
          reason: 'Should have sent exactly 3 chunks');
      expect((result['failedChunks'] as List).isNotEmpty, isTrue,
          reason: 'Should have recorded some failed chunks');
    });

    test('should validate data integrity after partial transfer', () async {
      // Arrange: setup to transfer 5 chunks but only first 2 succeed
      final result = await runPartialTransferTest(
        successfulChunks: [0, 1], // Only first 2 chunks successful
        totalChunks: 5,
        isPreset: true,
        isLarge: true,
      );

      // Assert
      expect(result['success'], isFalse,
          reason: 'Transfer should fail with partial data');

      // Verify we captured some data but it's incomplete (may not be valid JSON)
      expect(result['hasValidData'], false,
          reason: 'Partial data should not be considered valid');
    });

    test('should recover from device restart during transfer', () async {
      // Setup to capture device restart scenarios
      final mockChannel = PartialTransferMockChannel(
        successfulChunks: [0, 1, 2, 3, 4], // All chunks could succeed
        totalChunks: 5,
        simulateDeviceRestart: true, // But device will restart
      );

      // Setup method channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.headphonemobileapp/ble_data'),
              mockChannel.handleMethodCall);

      // Execute the test
      final preset = PartialTransferTestData.createPreset(large: true);
      final result = await bleDataService.sendPresetData(preset);

      // Assertions
      expect(mockChannel.deviceRestartOccurred, isTrue,
          reason: 'Device restart should have been simulated');
      expect(result, isFalse,
          reason: 'Transfer should fail when device restarts');
    });

    test('should handle retry logic for partial transfers', () async {
      // Create mock for first attempt with only partial success
      final mockChannel = PartialTransferMockChannel(
        successfulChunks: [0, 1, 3], // Only these chunks succeed initially
        totalChunks: 5,
      );

      // Setup variable to modify behavior on retry
      int attemptCount = 0;

      // Setup method channel mock with custom handling
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('com.headphonemobileapp/ble_data'),
              (MethodCall methodCall) async {
        if (methodCall.method == 'writeCharacteristic') {
          // Get chunk index (first byte)
          final data = methodCall.arguments['data'] as Uint8List;
          final chunkIndex = data.isNotEmpty ? data[0] : -1;

          // Count each attempt on chunks we want to track
          if (chunkIndex == 2 || chunkIndex == 4) {
            attemptCount++;
          }

          // Make retry attempts succeed after initial failures
          if ((chunkIndex == 2 || chunkIndex == 4) && attemptCount > 3) {
            mockChannel.log(
                "Retry attempt #$attemptCount succeeded for chunk $chunkIndex");

            // Add to sentChunks so transferComplete can be evaluated
            mockChannel.sentChunks.add(chunkIndex);

            // If we now have all chunks, mark as complete
            if (mockChannel.sentChunks.toSet().length ==
                mockChannel.totalChunks) {
              mockChannel.transferComplete = true;
              mockChannel.log("Transfer completed after retries");
            }

            return true;
          }
        }

        // Use normal mock behavior for other calls
        return mockChannel.handleMethodCall(methodCall);
      });

      // Act - perform the transfer
      final preset = PartialTransferTestData.createPreset(large: true);
      final result = await bleDataService.sendPresetData(preset);

      // Log for debugging
      print("Transfer completed with result: $result");
      print("Sent chunks after all attempts: ${mockChannel.sentChunks}");
      print("Retry attempt count: $attemptCount");

      // Verify that retry attempts were made
      expect(attemptCount, greaterThanOrEqualTo(3),
          reason: 'Multiple retry attempts should have been made');

      // The implementation might either succeed (if retries work) or fail (if max retries exceeded)
      // Both outcomes are valid to test, depending on what the actual implementation does
      if (result) {
        expect(mockChannel.transferComplete, isTrue);
      } else {
        expect(mockChannel.sentChunks.toSet().length,
            lessThan(mockChannel.totalChunks),
            reason: 'Failed transfer should not have sent all chunks');
      }
    });
  });
}
