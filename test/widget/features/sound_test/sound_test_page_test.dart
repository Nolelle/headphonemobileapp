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
  // Add a mock implementation of _localizedStrings to prevent LateInitializationError
  late final Map<String, String> _localizedStrings = {
    'reset_test': 'Reset Test?',
    'confirm_reset': 'Reset Test?',
    'reset_test_confirmation':
        'This will reset all test values to zero. Continue?',
    'confirm_reset_message':
        'This will reset all test values to zero. Continue?',
    'cancel': 'Cancel',
    'reset': 'Reset',
    'take_test': 'Take Test',
    'your_audiogram': 'Your Audiogram',
    'audio_profile': 'Audio Profile',
    'hearing_test': 'Hearing Test',
    'audiogram_description':
        'This is your audiogram showing your hearing sensitivity at different frequencies',
    'left_ear': 'Left Ear',
    'right_ear': 'Right Ear',
    'frequency': 'Frequency',
    'hearing_level': 'Hearing Level',
    'normal_hearing': 'Normal Hearing',
    'mild_loss': 'Mild Loss',
    'moderate_loss': 'Moderate Loss',
    'severe_loss': 'Severe Loss',
    'profound_loss': 'Profound Loss',
    'reset_to_baseline': 'Reset to Baseline',
    'retake_test': 'Retake Test',
    'share_via_bluetooth': 'Share via Bluetooth',
    'start_test': 'Start Test',
    'welcome_hearing_test': 'Welcome to the Hearing Test',
    'take_hearing_test_message':
        'Take a hearing test to personalize your audio experience',
  };

  @override
  Future<bool> load() async {
    return true;
  }

  @override
  String translate(String key) {
    return _localizedStrings[key] ?? key;
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

      // Look for ElevatedButton.icon with Icon
      final shareButton = find.byType(ElevatedButton);

      // Verify at least one ElevatedButton exists
      expect(shareButton, findsWidgets);

      // Find the icon widget to verify it's a share button
      expect(find.byIcon(Icons.share), findsOneWidget);
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
