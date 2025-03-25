import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/features/bluetooth/views/widgets/bluetooth_wrapper.dart';
import 'package:projects/l10n/app_localizations.dart';
import '../../../unit/mocks/mock_setup.mocks.dart';

// Mock AppLocalizations for testing
class MockAppLocalizations implements AppLocalizations {
  @override
  final Locale locale;

  MockAppLocalizations([this.locale = const Locale('en')]);

  @override
  Future<bool> load() async {
    return true;
  }

  @override
  String translate(String key) {
    final Map<String, String> translations = {
      'connect_bluetooth': 'Connect Bluetooth',
      'please_connect': 'Please connect your Bluetooth headphones',
      'app_requires_bt':
          'To use this app, you need to connect your Bluetooth headphones',
      'open_bt_settings': 'Open Bluetooth Settings',
      'check_connected_devices': 'Check for Connected Devices',
      'cancel': 'Cancel',
      'no_connected_devices': 'No connected devices found',
    };
    return translations[key] ?? key;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock AppLocalizations delegate for testing
class MockAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => MockAppLocalizations();

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BluetoothWrapper Widget Tests', () {
    late MockBluetoothProvider mockBluetoothProvider;

    setUp(() {
      mockBluetoothProvider = MockBluetoothProvider();
    });

    Widget createTestableWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: [
          MockAppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        home: ChangeNotifierProvider<BluetoothProvider>.value(
          value: mockBluetoothProvider,
          child: child,
        ),
      );
    }

    testWidgets('should display connection UI when no device is connected',
        (WidgetTester tester) async {
      // Arrange
      when(mockBluetoothProvider.isDeviceConnected).thenReturn(false);
      when(mockBluetoothProvider.connectedDeviceName).thenReturn("No Device");
      when(mockBluetoothProvider.isBluetoothEnabled).thenReturn(true);

      // The child widget that should NOT be displayed when no device is connected
      final childWidget = Container(
        key: const Key('child_widget'),
        child: const Text('Child Widget Content'),
      );

      // Act
      await tester.pumpWidget(createTestableWidget(
        BluetoothWrapper(child: childWidget),
      ));

      await tester.pumpAndSettle();

      // Assert
      // Should show connection UI, not the child widget
      expect(find.text('Connect Bluetooth'), findsOneWidget);
      expect(find.text('Please connect your Bluetooth headphones'),
          findsOneWidget);
      expect(
          find.text(
              'To use this app, you need to connect your Bluetooth headphones'),
          findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_searching), findsOneWidget);

      // Connection buttons should be visible
      expect(find.text('Open Bluetooth Settings'), findsOneWidget);
      expect(find.text('Check For Devices'), findsOneWidget);

      // Child widget should NOT be displayed
      expect(find.byKey(const Key('child_widget')), findsNothing);
      expect(find.text('Child Widget Content'), findsNothing);
    });

    testWidgets('should display child widget when device is connected',
        (WidgetTester tester) async {
      // Arrange
      when(mockBluetoothProvider.isDeviceConnected).thenReturn(true);
      when(mockBluetoothProvider.connectedDeviceName)
          .thenReturn("Test Headphones");
      when(mockBluetoothProvider.isBluetoothEnabled).thenReturn(true);

      // The child widget that SHOULD be displayed when a device is connected
      final childWidget = Container(
        key: const Key('child_widget'),
        child: const Text('Child Widget Content'),
      );

      // Act
      await tester.pumpWidget(createTestableWidget(
        BluetoothWrapper(child: childWidget),
      ));

      await tester.pumpAndSettle();

      // Assert
      // Should show the child widget, not the connection UI
      expect(find.byKey(const Key('child_widget')), findsOneWidget);
      expect(find.text('Child Widget Content'), findsOneWidget);

      // Connection UI should NOT be displayed
      expect(find.text('Connect Bluetooth'), findsNothing);
      expect(
          find.text('Please connect your Bluetooth headphones'), findsNothing);
      expect(find.byIcon(Icons.bluetooth_searching), findsNothing);
    });
  });
}
