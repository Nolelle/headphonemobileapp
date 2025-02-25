// File: lib/features/bluetooth/platform/bluetooth_platform.dart

import 'package:flutter/services.dart';

class BluetoothPlatform {
  static const platform = MethodChannel('com.headphonemobileapp/bluetooth');

  static Future<bool> isAudioDeviceConnected() async {
    try {
      final bool hasConnectedAudioDevice =
          await platform.invokeMethod('isAudioDeviceConnected');
      return hasConnectedAudioDevice;
    } on PlatformException catch (e) {
      print("Failed to get audio devices from platform: ${e.message}");
      return false;
    }
  }
}
