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
import 'test_page_hearing_test.mocks.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String translate(String key) {
    switch (key) {
      case 'start_test':
        return 'Start Test';
      case 'begin_sound_test':
        return 'Begin Sound Test';
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
      case 'test_complete':
        return 'Test Complete';
      case 'test_complete_message':
        return 'You have completed the hearing test';
      case 'hearing_test_in_progress':
        return 'Hearing Test in Progress';
      case 'prepare_for_hearing_test':
        return 'Prepare for Hearing Test';
      case 'some_instructions_before_starting':
        return 'Some Instructions Before Starting';
      case 'sit_in_quiet_environment':
        return 'Sit in a quiet environment';
      case 'set_max_volume':
        return 'Set maximum volume';
      case 'wear_headphones_properly':
        return 'Wear headphones properly';
      case 'ok':
        return 'OK';
      default:
        return key;
    }
  }
}

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

  group('TestPage Hearing Test Logic', () {
    late MockSoundTestProvider mockSoundTestProvider;
    late SoundTest updatedSoundTest;
    late MockAudioPlayer mockAudioPlayer;

    setUp(() {
      mockSoundTestProvider = MockSoundTestProvider();
      mockAudioPlayer = MockAudioPlayer();

      // Mock audio player methods
      when(mockAudioPlayer.setVolume(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.setPlayerMode(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.setReleaseMode(any)).thenAnswer((_) async => 0);
      when(mockAudioPlayer.play(any,
              balance: anyNamed('balance'), volume: anyNamed('volume')))
          .thenAnswer((_) async => 0);
      when(mockAudioPlayer.stop()).thenAnswer((_) async => 0);
      when(mockAudioPlayer.release()).thenAnswer((_) async => 0);
      when(mockAudioPlayer.dispose()).thenAnswer((_) async => 0);

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

      // Capture the updated sound test
      updatedSoundTest = SoundTest(
        id: 'not_set',
        name: 'not_set',
        dateCreated: DateTime(2023, 1, 1),
        soundTestData: {},
      );

      when(mockSoundTestProvider.updateSoundTest(any)).thenAnswer((invocation) {
        updatedSoundTest = invocation.positionalArguments[0] as SoundTest;
        return Future.value(null);
      });
    });

    // Properly settle any pending timers in the test
    Future<void> pumpAndSettleWithTimers(WidgetTester tester,
        {bool skipTimers = false}) async {
      // First, pump and settle regular widgets
      await tester.pumpAndSettle();

      if (!skipTimers) {
        // Handle the toast timer by pumping with a longer duration
        await tester.pump(const Duration(seconds: 3));

        // Handle the delayed timer in dispose method
        await tester.pump(const Duration(milliseconds: 300));
      }

      // Final pump to ensure everything is settled
      await tester.pumpAndSettle();
    }

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

    testWidgets(
        'hearing test sequence detects threshold correctly for left ear first frequency',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build widget
      await tester.pumpWidget(buildTestableWidget());
      await pumpAndSettleWithTimers(tester);

      // Start the test
      await tester.tap(find.text('Begin Sound Test'));
      await pumpAndSettleWithTimers(tester);

      // Get the state to access internal values
      final state = tester.state<State<TestPage>>(find.byType(TestPage));
      final testPageState = state as dynamic;

      // Verify test is in progress with left ear and first frequency
      expect(testPageState.start_pressed, true);
      expect(testPageState.current_ear, 'L');
      expect(testPageState.current_sound_stage, 1);
      expect(testPageState.is_finding_threshold, false);

      // Simulate the user pressing "I can hear it" button initially (volume decreases)
      await tester.tap(find.text('I can hear it'));
      await pumpAndSettleWithTimers(tester);

      // Check that volume decreased
      final initialVolume = testPageState.current_volume;

      // Simulate user pressing "I can hear it" multiple times until reaching threshold
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('I can hear it'));
        await pumpAndSettleWithTimers(tester);
      }

      // Now volume should be lower
      expect(testPageState.current_volume < initialVolume, true);

      // Simulate the user pressing "I cannot hear it" to indicate threshold is reached
      await tester.tap(find.text('I cannot hear it'));
      await pumpAndSettleWithTimers(tester);

      // Verify threshold finding is activated
      expect(testPageState.is_finding_threshold, true);
      expect(testPageState.last_heard_db > 0, true);

      // Simulate confirming the threshold by pressing "I can hear it"
      await tester.tap(find.text('I can hear it'));
      await pumpAndSettleWithTimers(tester);

      // Verify the threshold was saved and we moved to the next frequency
      expect(testPageState.current_sound_stage, 2);
      expect(testPageState.is_finding_threshold, false);

      // Verify that updateSoundTest was called with the correct values
      verify(mockSoundTestProvider.updateSoundTest(any)).called(greaterThan(0));
      expect(updatedSoundTest.id, 'test123');
      expect(updatedSoundTest.soundTestData['L_user_250Hz_dB'] != 0.0, true);

      // Manually stop the sound and cleanup to avoid timer conflicts
      testPageState.stopSound();

      // Skip timer handling on the final pump to avoid conflicts with pending timers
      await pumpAndSettleWithTimers(tester, skipTimers: true);
    });

    testWidgets(
        'hearing test successfully transitions between frequencies and ears',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build widget
      await tester.pumpWidget(buildTestableWidget());
      await pumpAndSettleWithTimers(tester);

      // Start the test
      await tester.tap(find.text('Begin Sound Test'));
      await pumpAndSettleWithTimers(tester);

      // Get the state to access internal values
      final state = tester.state<State<TestPage>>(find.byType(TestPage));
      final testPageState = state as dynamic;

      // Complete just the first frequency for left ear to demonstrate transitions
      expect(testPageState.current_ear, 'L');
      expect(testPageState.current_sound_stage, 1);

      // Simulate "I cannot hear it" to find threshold
      await tester.tap(find.text('I cannot hear it'));
      await pumpAndSettleWithTimers(tester);

      // Simulate "I can hear it" to confirm and move to next stage
      await tester.tap(find.text('I can hear it'));
      await pumpAndSettleWithTimers(tester);

      // Verify we moved to the next frequency
      expect(testPageState.current_ear, 'L');
      expect(testPageState.current_sound_stage, 2);

      // Simulate "I cannot hear it" for the second frequency
      await tester.tap(find.text('I cannot hear it'));
      await pumpAndSettleWithTimers(tester);

      // Simulate "I can hear it" to confirm
      await tester.tap(find.text('I can hear it'));
      await pumpAndSettleWithTimers(tester);

      // Verify we've moved to the third frequency
      expect(testPageState.current_ear, 'L');
      expect(testPageState.current_sound_stage, 3);

      // Verify thresholds were saved for the completed frequencies
      verify(mockSoundTestProvider.updateSoundTest(any)).called(greaterThan(1));
      expect(updatedSoundTest.soundTestData['L_user_250Hz_dB'] != 0.0, true);
      expect(updatedSoundTest.soundTestData['L_user_500Hz_dB'] != 0.0, true);

      // Manually stop the sound and cleanup to avoid timer conflicts
      testPageState.stopSound();

      // Skip timer handling on the final pump to avoid conflicts
      await pumpAndSettleWithTimers(tester, skipTimers: true);
    });

    testWidgets('test saves correct hearing threshold values in expected range',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build widget
      await tester.pumpWidget(buildTestableWidget());
      await pumpAndSettleWithTimers(tester);

      // Start the test
      await tester.tap(find.text('Begin Sound Test'));
      await pumpAndSettleWithTimers(tester);

      // Get the state to access internal values
      final state = tester.state<State<TestPage>>(find.byType(TestPage));
      final testPageState = state as dynamic;

      // Focus on testing just one frequency for accuracy verification
      expect(testPageState.current_ear, 'L');
      expect(testPageState.current_sound_stage, 1);

      // Record the initial volume and set a custom value for testing
      final initialVolume = testPageState.current_volume;
      final initialDBSPL = testPageState.convertVolumeToDBSPL(initialVolume);

      // Manually set the volume to a known value for predictable test results
      testPageState.setCurrentVolume(0.5);
      final testDBSPL = testPageState.convertVolumeToDBSPL(0.5);

      // Simulate "I cannot hear it" to find threshold
      await tester.tap(find.text('I cannot hear it'));
      await pumpAndSettleWithTimers(tester);

      // Verify we're in threshold finding mode
      expect(testPageState.is_finding_threshold, true);

      // Check if last_heard_db is in the expected range
      final expectedLastHeardDb = testDBSPL + testPageState.STEP_DOWN_DB;
      final tolerance = 5.0; // Allow 5 dB tolerance
      expect(
          testPageState.last_heard_db,
          inInclusiveRange(expectedLastHeardDb - tolerance,
              expectedLastHeardDb + tolerance));

      // Simulate "I can hear it" to confirm threshold
      await tester.tap(find.text('I can hear it'));
      await pumpAndSettleWithTimers(tester);

      // Convert the expected dB SPL to dB HL for 250Hz - this can have slight variations
      final expectedDBHL = testPageState.convertDBSPLtoDBHL(testDBSPL, 250);

      // Verify the correct threshold was saved with some tolerance
      expect(testPageState.L_user_250Hz_dB,
          inInclusiveRange(expectedDBHL - tolerance, expectedDBHL + tolerance));

      expect(updatedSoundTest.soundTestData['L_user_250Hz_dB'],
          inInclusiveRange(expectedDBHL - tolerance, expectedDBHL + tolerance));

      // Manually stop the sound and cleanup to avoid timer conflicts
      testPageState.stopSound();

      // Skip timer handling on the final pump to avoid conflicts
      await pumpAndSettleWithTimers(tester, skipTimers: true);
    });

    testWidgets(
        'test handles volume changes correctly during threshold detection',
        (WidgetTester tester) async {
      await setLargeScreenSize(tester);

      // Build widget
      await tester.pumpWidget(buildTestableWidget());
      await pumpAndSettleWithTimers(tester);

      // Start the test
      await tester.tap(find.text('Begin Sound Test'));
      await pumpAndSettleWithTimers(tester);

      // Get the state to access internal values
      final state = tester.state<State<TestPage>>(find.byType(TestPage));
      final testPageState = state as dynamic;

      // Record the initial volume
      final initialVolume = testPageState.current_volume;
      final initialDBSPL = testPageState.convertVolumeToDBSPL(initialVolume);

      // Press "I can hear it" to decrease volume
      await tester.tap(find.text('I can hear it'));
      await pumpAndSettleWithTimers(tester);

      // Verify volume decreased
      final decreasedVolume = testPageState.current_volume;
      final decreasedDBSPL =
          testPageState.convertVolumeToDBSPL(decreasedVolume);
      expect(decreasedDBSPL < initialDBSPL, true);

      // Use a tolerance for the step value
      final tolerance = 1.0; // 1 dB tolerance
      expect(
          initialDBSPL - decreasedDBSPL,
          inInclusiveRange(testPageState.STEP_DOWN_DB - tolerance,
              testPageState.STEP_DOWN_DB + tolerance));

      // Press "I cannot hear it" to trigger threshold finding
      await tester.tap(find.text('I cannot hear it'));
      await pumpAndSettleWithTimers(tester);

      // Verify we're in threshold finding mode and volume increased
      expect(testPageState.is_finding_threshold, true);
      final confirmationVolume = testPageState.current_volume;
      final confirmationDBSPL =
          testPageState.convertVolumeToDBSPL(confirmationVolume);
      expect(confirmationDBSPL > decreasedDBSPL, true);
      expect(
          confirmationDBSPL - decreasedDBSPL,
          inInclusiveRange(testPageState.STEP_UP_DB - tolerance,
              testPageState.STEP_UP_DB + tolerance));

      // Manually stop the sound and cleanup to avoid timer conflicts
      testPageState.stopSound();

      // Skip timer handling on the final pump to avoid conflicts
      await pumpAndSettleWithTimers(tester, skipTimers: true);
    });
  });
}
