// Mocks generated by Mockito 5.4.5 from annotations
// in projects/test/widget/features/sound_test/sound_test_page_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:ui' as _i5;

import 'package:flutter/material.dart' as _i9;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;
import 'package:projects/features/bluetooth/platform/bluetooth_platform.dart'
    as _i8;
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart'
    as _i6;
import 'package:projects/features/sound_test/models/sound_test.dart' as _i3;
import 'package:projects/features/sound_test/providers/sound_test_provider.dart'
    as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [SoundTestProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockSoundTestProvider extends _i1.Mock implements _i2.SoundTestProvider {
  @override
  Map<String, _i3.SoundTest> get soundTests =>
      (super.noSuchMethod(
            Invocation.getter(#soundTests),
            returnValue: <String, _i3.SoundTest>{},
            returnValueForMissingStub: <String, _i3.SoundTest>{},
          )
          as Map<String, _i3.SoundTest>);

  @override
  bool get isLoading =>
      (super.noSuchMethod(
            Invocation.getter(#isLoading),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(
            Invocation.getter(#hasListeners),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  _i4.Future<void> fetchSoundTests() =>
      (super.noSuchMethod(
            Invocation.method(#fetchSoundTests, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> createSoundTest(_i3.SoundTest? soundTest) =>
      (super.noSuchMethod(
            Invocation.method(#createSoundTest, [soundTest]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> updateSoundTest(_i3.SoundTest? soundTest) =>
      (super.noSuchMethod(
            Invocation.method(#updateSoundTest, [soundTest]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> resetSoundTest(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#resetSoundTest, [id]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void setActiveSoundTest(String? id) => super.noSuchMethod(
    Invocation.method(#setActiveSoundTest, [id]),
    returnValueForMissingStub: null,
  );

  @override
  void clearActiveSoundTest() => super.noSuchMethod(
    Invocation.method(#clearActiveSoundTest, []),
    returnValueForMissingStub: null,
  );

  @override
  _i3.SoundTest? getSoundTestById(String? id) =>
      (super.noSuchMethod(
            Invocation.method(#getSoundTestById, [id]),
            returnValueForMissingStub: null,
          )
          as _i3.SoundTest?);

  @override
  void clearError() => super.noSuchMethod(
    Invocation.method(#clearError, []),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [BluetoothProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothProvider extends _i1.Mock implements _i6.BluetoothProvider {
  @override
  bool get isDeviceConnected =>
      (super.noSuchMethod(
            Invocation.getter(#isDeviceConnected),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get isBluetoothEnabled =>
      (super.noSuchMethod(
            Invocation.getter(#isBluetoothEnabled),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  String get connectedDeviceName =>
      (super.noSuchMethod(
            Invocation.getter(#connectedDeviceName),
            returnValue: _i7.dummyValue<String>(
              this,
              Invocation.getter(#connectedDeviceName),
            ),
            returnValueForMissingStub: _i7.dummyValue<String>(
              this,
              Invocation.getter(#connectedDeviceName),
            ),
          )
          as String);

  @override
  bool get isScanning =>
      (super.noSuchMethod(
            Invocation.getter(#isScanning),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  List<_i8.BluetoothDevice> get scanResults =>
      (super.noSuchMethod(
            Invocation.getter(#scanResults),
            returnValue: <_i8.BluetoothDevice>[],
            returnValueForMissingStub: <_i8.BluetoothDevice>[],
          )
          as List<_i8.BluetoothDevice>);

  @override
  _i8.BluetoothAudioType get audioType =>
      (super.noSuchMethod(
            Invocation.getter(#audioType),
            returnValue: _i8.BluetoothAudioType.none,
            returnValueForMissingStub: _i8.BluetoothAudioType.none,
          )
          as _i8.BluetoothAudioType);

  @override
  bool get isUsingLEAudio =>
      (super.noSuchMethod(
            Invocation.getter(#isUsingLEAudio),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(
            Invocation.getter(#hasListeners),
            returnValue: false,
            returnValueForMissingStub: false,
          )
          as bool);

  @override
  _i4.Future<void> saveConnectionState() =>
      (super.noSuchMethod(
            Invocation.method(#saveConnectionState, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> loadConnectionState() =>
      (super.noSuchMethod(
            Invocation.method(#loadConnectionState, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> refreshBatteryLevel() =>
      (super.noSuchMethod(
            Invocation.method(#refreshBatteryLevel, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> updateConnectionFromDevice(
    _i8.BluetoothDevice? device,
    _i8.BluetoothAudioType? audioType,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updateConnectionFromDevice, [device, audioType]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> forceAudioRouting() =>
      (super.noSuchMethod(
            Invocation.method(#forceAudioRouting, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  void setBypassMode(bool? bypass) => super.noSuchMethod(
    Invocation.method(#setBypassMode, [bypass]),
    returnValueForMissingStub: null,
  );

  @override
  void setBypassBluetoothCheck(bool? bypass) => super.noSuchMethod(
    Invocation.method(#setBypassBluetoothCheck, [bypass]),
    returnValueForMissingStub: null,
  );

  @override
  _i4.Future<void> startScan() =>
      (super.noSuchMethod(
            Invocation.method(#startScan, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> stopScan() =>
      (super.noSuchMethod(
            Invocation.method(#stopScan, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> checkBluetoothConnection() =>
      (super.noSuchMethod(
            Invocation.method(#checkBluetoothConnection, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> registerDevice(_i8.BluetoothDevice? device) =>
      (super.noSuchMethod(
            Invocation.method(#registerDevice, [device]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> connectToDevice(_i8.BluetoothDevice? device) =>
      (super.noSuchMethod(
            Invocation.method(#connectToDevice, [device]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> disconnectDevice() =>
      (super.noSuchMethod(
            Invocation.method(#disconnectDevice, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> deregisterDevice() =>
      (super.noSuchMethod(
            Invocation.method(#deregisterDevice, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> connectViaSystemSettings() =>
      (super.noSuchMethod(
            Invocation.method(#connectViaSystemSettings, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<void> reconnectDevice() =>
      (super.noSuchMethod(
            Invocation.method(#reconnectDevice, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<bool> verifyAudioConnection() =>
      (super.noSuchMethod(
            Invocation.method(#verifyAudioConnection, []),
            returnValue: _i4.Future<bool>.value(false),
            returnValueForMissingStub: _i4.Future<bool>.value(false),
          )
          as _i4.Future<bool>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void addListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i5.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [NavigatorObserver].
///
/// See the documentation for Mockito's code generation for more information.
class MockNavigatorObserver extends _i1.Mock implements _i9.NavigatorObserver {
  @override
  void didPush(_i9.Route<dynamic>? route, _i9.Route<dynamic>? previousRoute) =>
      super.noSuchMethod(
        Invocation.method(#didPush, [route, previousRoute]),
        returnValueForMissingStub: null,
      );

  @override
  void didPop(_i9.Route<dynamic>? route, _i9.Route<dynamic>? previousRoute) =>
      super.noSuchMethod(
        Invocation.method(#didPop, [route, previousRoute]),
        returnValueForMissingStub: null,
      );

  @override
  void didRemove(
    _i9.Route<dynamic>? route,
    _i9.Route<dynamic>? previousRoute,
  ) => super.noSuchMethod(
    Invocation.method(#didRemove, [route, previousRoute]),
    returnValueForMissingStub: null,
  );

  @override
  void didReplace({
    _i9.Route<dynamic>? newRoute,
    _i9.Route<dynamic>? oldRoute,
  }) => super.noSuchMethod(
    Invocation.method(#didReplace, [], {
      #newRoute: newRoute,
      #oldRoute: oldRoute,
    }),
    returnValueForMissingStub: null,
  );

  @override
  void didChangeTop(
    _i9.Route<dynamic>? topRoute,
    _i9.Route<dynamic>? previousTopRoute,
  ) => super.noSuchMethod(
    Invocation.method(#didChangeTop, [topRoute, previousTopRoute]),
    returnValueForMissingStub: null,
  );

  @override
  void didStartUserGesture(
    _i9.Route<dynamic>? route,
    _i9.Route<dynamic>? previousRoute,
  ) => super.noSuchMethod(
    Invocation.method(#didStartUserGesture, [route, previousRoute]),
    returnValueForMissingStub: null,
  );

  @override
  void didStopUserGesture() => super.noSuchMethod(
    Invocation.method(#didStopUserGesture, []),
    returnValueForMissingStub: null,
  );
}
