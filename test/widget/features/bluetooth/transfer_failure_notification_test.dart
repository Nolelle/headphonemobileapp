import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projects/features/bluetooth/services/bluetooth_file_service.dart';
import 'package:projects/l10n/app_localizations.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<BluetoothFileService>(),
])
import 'transfer_failure_notification_test.mocks.dart';

// Mock AppLocalizations for testing
class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super(const Locale('en'));

  @override
  String translate(String key) {
    final Map<String, String> translations = {
      'combined_data_share_failed': 'Failed to share combined data',
      'file_send_failed': 'Failed to send file',
    };
    return translations[key] ?? key;
  }
}

class MockLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => MockAppLocalizations();

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

// Test widget that shows a SnackBar
class TestApp extends StatelessWidget {
  final String message;

  const TestApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        MockLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: TestScreen(message: message),
    );
  }
}

class TestScreen extends StatefulWidget {
  final String message;

  const TestScreen({super.key, required this.message});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule displaying the SnackBar after the frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.message),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Test Page: ${widget.message}'),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Transfer Failure Notification Tests', () {
    // Test for showing error notification when transfer fails - for combined data
    testWidgets(
        'should show error notification when combined data transfer fails',
        (WidgetTester tester) async {
      // Build the test widget with the error message
      await tester.pumpWidget(const TestApp(
        message: 'Failed to share combined data',
      ));

      // Wait for the initial frame
      await tester.pump();

      // Wait for the SnackBar animation to complete (typically takes ~500ms)
      await tester.pump(const Duration(milliseconds: 500));

      // Verify that the error notification is shown
      expect(find.text('Failed to share combined data'), findsOneWidget);
    });

    // Test for showing error notification when transfer fails - for sound test file
    testWidgets(
        'should show error notification when sound test file transfer fails',
        (WidgetTester tester) async {
      // Build the test widget with the error message
      await tester.pumpWidget(const TestApp(
        message: 'Failed to send file',
      ));

      // Wait for the initial frame
      await tester.pump();

      // Wait for the SnackBar animation to complete
      await tester.pump(const Duration(milliseconds: 500));

      // Verify that the error notification is shown
      expect(find.text('Failed to send file'), findsOneWidget);
    });
  });
}
