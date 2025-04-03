import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:projects/features/sound_test/views/screens/test_page.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/l10n/app_localizations.dart';

@GenerateNiceMocks([
  MockSpec<SoundTestProvider>(),
  MockSpec<AudioPlayer>(),
])
import 'test_page_test.mocks.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String translate(String key) {
    switch (key) {
      case 'start_test':
        return 'Start Test';
      case 'how_it_works':
        return 'How It Works';
      case 'i_can_hear_it':
        return 'I can hear it';
      case 'i_cannot_hear_it':
        return 'I cannot hear it';
      case 'left_ear':
        return 'Left Ear';
      case 'right_ear':
        return 'Right Ear';
      case 'test_completed':
        return 'Test Completed';
      case 'test_completed_message':
        return 'You have completed the hearing test';
      case 'test_sound_profile':
        return 'Test Sound Profile';
      case 'frequency':
        return 'Frequency';
      case 'hz':
        return 'Hz';
      case 'ok':
        return 'OK';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TestPage Widget Tests', () {
    late MockSoundTestProvider mockSoundTestProvider;
    late MockAudioPlayer mockAudioPlayer;

    setUp(() {
      mockSoundTestProvider = MockSoundTestProvider();
      mockAudioPlayer = MockAudioPlayer();

      // Mock player methods to avoid platform method errors
      when(mockAudioPlayer.setVolume(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.setPlayerMode(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.setReleaseMode(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.setSourceAsset(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.setBalance(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.stop()).thenAnswer((_) async => 0);
      when(mockAudioPlayer.play(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.release()).thenAnswer((_) async => 0);

      // Mock sound test provider methods
      when(mockSoundTestProvider.getSoundTestById(any)).thenReturn(
        SoundTest(
          id: 'test123',
          name: 'Test Sound Profile',
          dateCreated: DateTime(2023, 1, 1),
          soundTestData: {
            'L_user_250Hz_dB': 0.0,
            'L_user_500Hz_dB': 0.0,
            'L_user_1000Hz_dB': 0.0,
            'L_user_2000Hz_dB': 0.0,
            'L_user_4000Hz_dB': 0.0,
            'R_user_250Hz_dB': 0.0,
            'R_user_500Hz_dB': 0.0,
            'R_user_1000Hz_dB': 0.0,
            'R_user_2000Hz_dB': 0.0,
            'R_user_4000Hz_dB': 0.0,
          },
        ),
      );
      when(mockSoundTestProvider.updateSoundTest(any))
          .thenAnswer((_) async => {});
    });

    // Adjust test screen size to be larger to accommodate the UI
    Future<void> setLargeScreenSize(WidgetTester tester) async {
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      tester.binding.window.physicalSizeTestValue = const Size(1024, 1024);
      addTearDown(() {
        tester.binding.window.clearDevicePixelRatioTestValue();
        tester.binding.window.clearPhysicalSizeTestValue();
      });
    }

    Widget buildTestableWidget() {
      return MaterialApp(
        home: TestPage(
          soundTestId: 'test123',
          soundTestName: 'Test Sound Profile',
          soundTestProvider: mockSoundTestProvider,
        ),
        localizationsDelegates: [
          AppLocalizationsDelegate(),
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
      );
    }

    // Mock the AudioPlayer creation in the TestPage
    Future<TestPage> createTestPage({
      required WidgetTester tester,
      required String testId,
      String? testName,
    }) async {
      final widget = TestPage(
        soundTestId: testId,
        soundTestName: testName,
        soundTestProvider: mockSoundTestProvider,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: widget,
          localizationsDelegates: [
            AppLocalizationsDelegate(),
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
        ),
      );

      await tester.pumpAndSettle();

      return widget;
    }

    testWidgets('renders initial test page with start button',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build widget
      await tester.pumpWidget(buildTestableWidget());

      await tester.pumpAndSettle();

      // Verify initial UI state
      expect(find.text('Test Sound Profile'), findsOneWidget);
      expect(find.text('Start Test'), findsOneWidget);

      // Verify test instructions are displayed
      expect(find.text('How It Works'), findsOneWidget);
    });

    testWidgets('clicking start button enters test mode',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Create and build widget
      await createTestPage(
          tester: tester, testId: 'test123', testName: 'Test Sound Profile');

      // Get the initial state
      final state = tester.state<State<TestPage>>(find.byType(TestPage));

      // Verify initial state
      expect((state as dynamic).start_pressed, false);

      // Find and tap the start button
      final startButton = find.text('Start Test');
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Verify state changes
      expect((state as dynamic).start_pressed, true);

      // Check for hearing test UI components
      expect(find.text('I can hear it'), findsOneWidget);
      expect(find.text('I cannot hear it'), findsOneWidget);
    });

    testWidgets('shows frequency display during test',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Create and build widget
      await createTestPage(
          tester: tester, testId: 'test123', testName: 'Test Sound Profile');

      // Get the state
      final state = tester.state<State<TestPage>>(find.byType(TestPage));

      // Set state to simulate test in progress
      state.setState(() {
        (state as dynamic).start_pressed = true;
        (state as dynamic).current_ear = 'L'; // Left ear
        (state as dynamic).current_sound_stage = 1; // First stage (250Hz)
      });

      await tester.pumpAndSettle();

      // Verify test UI elements
      expect(find.text('I can hear it'), findsOneWidget);
      expect(find.text('I cannot hear it'), findsOneWidget);

      // Left ear should be shown
      expect(find.text('Left Ear'), findsOneWidget);
    });
  });
}
