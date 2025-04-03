import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:projects/features/sound_test/views/screens/sound_test_page.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/bluetooth/providers/bluetooth_provider.dart';
import 'package:projects/l10n/app_localizations.dart';
import 'package:projects/features/sound_test/widgets/audiogram.dart';

@GenerateNiceMocks([
  MockSpec<SoundTestProvider>(),
  MockSpec<BluetoothProvider>(),
  MockSpec<NavigatorObserver>(),
])
import 'sound_test_page_test.mocks.dart';

// Helper function to create standard test data with the same value for all frequencies
Map<String, double> createStandardTestData(double value) {
  return {
    'L_user_250Hz_dB': value,
    'L_user_500Hz_dB': value,
    'L_user_1000Hz_dB': value,
    'L_user_2000Hz_dB': value,
    'L_user_4000Hz_dB': value,
    'R_user_250Hz_dB': value,
    'R_user_500Hz_dB': value,
    'R_user_1000Hz_dB': value,
    'R_user_2000Hz_dB': value,
    'R_user_4000Hz_dB': value,
  };
}

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String translate(String key) {
    switch (key) {
      case 'reset_test':
      case 'confirm_reset':
        return 'Reset Test?';
      case 'reset_test_confirmation':
      case 'confirm_reset_message':
        return 'This will reset all test values to zero. Continue?';
      case 'cancel':
        return 'Cancel';
      case 'reset':
        return 'Reset';
      case 'take_test':
        return 'Take Test';
      case 'your_audiogram':
        return 'Your Audiogram';
      case 'audio_profile':
        return 'Audio Profile';
      case 'hearing_test':
        return 'Hearing Test';
      case 'audiogram_description':
        return 'This is your audiogram showing your hearing sensitivity at different frequencies';
      case 'left_ear':
        return 'Left Ear';
      case 'right_ear':
        return 'Right Ear';
      case 'frequency':
        return 'Frequency';
      case 'hearing_level':
        return 'Hearing Level';
      case 'normal_hearing':
        return 'Normal Hearing';
      case 'mild_loss':
        return 'Mild Loss';
      case 'moderate_loss':
        return 'Moderate Loss';
      case 'severe_loss':
        return 'Severe Loss';
      case 'profound_loss':
        return 'Profound Loss';
      case 'reset_to_baseline':
        return 'Reset to Baseline';
      case 'retake_test':
        return 'Retake Test';
      case 'share_via_bluetooth':
        return 'Share via Bluetooth';
      case 'start_test':
        return 'Start Test';
      case 'welcome_hearing_test':
        return 'Welcome to the Hearing Test';
      case 'take_hearing_test_message':
        return 'Take a hearing test to personalize your audio experience';
      default:
        return key;
    }
  }
}

// Wrapper for localization
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async => MockAppLocalizations();

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

void main() {
  group('SoundTestPage Tests', () {
    late MockSoundTestProvider mockSoundTestProvider;
    late MockBluetoothProvider mockBluetoothProvider;
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockSoundTestProvider = MockSoundTestProvider();
      mockBluetoothProvider = MockBluetoothProvider();
      mockNavigatorObserver = MockNavigatorObserver();

      // Set up the mock sound test provider to return test data
      when(mockSoundTestProvider.soundTests).thenReturn({
        'test1': SoundTest(
          id: 'test1',
          name: 'Test Profile',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: createStandardTestData(50.0),
        ),
      });
      when(mockSoundTestProvider.activeSoundTestId).thenReturn('test1');
      when(mockSoundTestProvider.isLoading).thenReturn(false);
      when(mockSoundTestProvider.getSoundTestById('test1')).thenReturn(
        SoundTest(
          id: 'test1',
          name: 'Test Profile',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: createStandardTestData(50.0),
        ),
      );

      // Mock the bluetooth provider
      when(mockBluetoothProvider.isDeviceConnected).thenReturn(false);
    });

    // Adjust test screen size to be larger to accommodate the audiogram
    Future<void> setLargeScreenSize(WidgetTester tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue =
          const Size(1024, 2048); // Make it taller
      addTearDown(() {
        tester.binding.window.clearDevicePixelRatioTestValue();
        tester.binding.window.clearPhysicalSizeTestValue();
      });
    }

    Widget buildTestableWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<SoundTestProvider>.value(
            value: mockSoundTestProvider,
          ),
          ChangeNotifierProvider<BluetoothProvider>.value(
            value: mockBluetoothProvider,
          ),
        ],
        child: MaterialApp(
          home: SoundTestPage(
            soundTestProvider: mockSoundTestProvider,
          ),
          navigatorObservers: [mockNavigatorObserver],
          localizationsDelegates: [
            AppLocalizationsDelegate(),
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
        ),
      );
    }

    testWidgets('renders correctly with audiogram',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build the widget
      await tester.pumpWidget(buildTestableWidget());

      // Wait for any frame callbacks or animations
      await tester.pumpAndSettle();

      // Verify that it renders without errors
      expect(find.byType(SoundTestPage), findsOneWidget);

      // Verify that the audiogram is displayed
      expect(find.byType(Audiogram), findsOneWidget);

      // Verify audiogram title is displayed
      expect(find.text('Your Audiogram'), findsOneWidget);
    });

    testWidgets('has reset to baseline button that can be tapped',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build widget with test data
      await tester.pumpWidget(buildTestableWidget());

      await tester.pumpAndSettle();

      // Look for the "Reset to Baseline" button which is shown on the audiogram page
      final resetButton =
          find.widgetWithText(ElevatedButton, 'Reset to Baseline');
      expect(resetButton, findsOneWidget);

      await tester.ensureVisible(resetButton);
      await tester.pumpAndSettle();

      // Tap the reset button
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Verify that the provider's updateSoundTest was called
      verify(mockSoundTestProvider.updateSoundTest(any)).called(1);
    });

    testWidgets('has retake test button that navigates',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build widget
      await tester.pumpWidget(buildTestableWidget());

      await tester.pumpAndSettle();

      // Look for the "Retake Test" button
      final retakeButton = find.widgetWithText(ElevatedButton, 'Retake Test');
      expect(retakeButton, findsOneWidget);

      await tester.ensureVisible(retakeButton);
      await tester.pumpAndSettle();

      // Tap the retake button
      await tester.tap(retakeButton);
      await tester.pumpAndSettle();

      // Verify navigation observation - a push event should have occurred
      verify(mockNavigatorObserver.didPush(any, any)).called(greaterThan(0));
    });

    testWidgets('has share via bluetooth button', (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build widget
      await tester.pumpWidget(buildTestableWidget());

      await tester.pumpAndSettle();

      // Look for the "Share via Bluetooth" button
      final shareButton =
          find.widgetWithText(ElevatedButton, 'Share via Bluetooth');
      expect(shareButton, findsOneWidget);
    });

    testWidgets('displays welcome screen when no test data',
        (WidgetTester tester) async {
      // Set up provider to return no test data
      when(mockSoundTestProvider.soundTests).thenReturn({});
      when(mockSoundTestProvider.activeSoundTestId).thenReturn(null);

      await setLargeScreenSize(tester);

      // Build widget
      await tester.pumpWidget(buildTestableWidget());

      await tester.pumpAndSettle();

      // Verify welcome screen elements
      expect(find.text('Welcome to the Hearing Test'), findsOneWidget);
      expect(
          find.text('Take a hearing test to personalize your audio experience'),
          findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Start Test'), findsOneWidget);
    });
  });
}
