import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/sound_test/models/sound_test.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/views/screens/test_page.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projects/l10n/app_localizations.dart';
import 'package:projects/l10n/translations/en.dart'; // Import the English translations

@GenerateMocks([AudioPlayer, SoundTestProvider])
import 'ear_switching_test.mocks.dart';

// Create a TestAppLocalizationsDelegate that doesn't require async loading
class TestAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const TestAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    // Set up the localizations with English translations directly
    localizations._localizedStrings = enTranslations;
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

// Create a mock EarSwitchWidget for testing
class EarSwitchWidget extends StatefulWidget {
  final AudioPlayer player;
  final Function(double) onBalanceChanged;
  final double initialBalance;

  const EarSwitchWidget({
    super.key,
    required this.player,
    required this.onBalanceChanged,
    required this.initialBalance,
  });

  @override
  State<EarSwitchWidget> createState() => _EarSwitchWidgetState();
}

class _EarSwitchWidgetState extends State<EarSwitchWidget> {
  late double _currentBalance;

  @override
  void initState() {
    super.initState();
    _currentBalance = widget.initialBalance;
    widget.player.setBalance(_currentBalance);
  }

  void _switchToLeftEar() {
    setState(() {
      _currentBalance = -1.0;
    });
    widget.player.setBalance(_currentBalance);
    widget.onBalanceChanged(_currentBalance);
  }

  void _switchToRightEar() {
    setState(() {
      _currentBalance = 1.0;
    });
    widget.player.setBalance(_currentBalance);
    widget.onBalanceChanged(_currentBalance);
  }

  void _switchToBothEars() {
    setState(() {
      _currentBalance = 0.0;
    });
    widget.player.setBalance(_currentBalance);
    widget.onBalanceChanged(_currentBalance);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Current Ear: ${_getCurrentEarText()}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _switchToLeftEar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentBalance == -1.0 ? Colors.blue : null,
              ),
              child: const Text('Left Ear'),
            ),
            ElevatedButton(
              onPressed: _switchToBothEars,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentBalance == 0.0 ? Colors.blue : null,
              ),
              child: const Text('Both Ears'),
            ),
            ElevatedButton(
              onPressed: _switchToRightEar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentBalance == 1.0 ? Colors.blue : null,
              ),
              child: const Text('Right Ear'),
            ),
          ],
        ),
      ],
    );
  }

  String _getCurrentEarText() {
    if (_currentBalance == -1.0) return 'Left';
    if (_currentBalance == 1.0) return 'Right';
    return 'Both';
  }
}

void main() {
  group('Ear Switching Tests', () {
    late MockSoundTestProvider mockProvider;
    late MockAudioPlayer mockAudioPlayer;

    setUp(() {
      mockProvider = MockSoundTestProvider();
      mockAudioPlayer = MockAudioPlayer();

      // Create a properly structured mock SoundTest that matches the real model
      final mockSoundTest = SoundTest(
        id: 'test123',
        dateCreated: DateTime.now(),
        name: 'Test Sound Test',
        soundTestData: {
          'L_user_250Hz_dB': -10.0,
          'L_user_500Hz_dB': -10.0,
          'L_user_1000Hz_dB': -10.0,
          'L_user_2000Hz_dB': -10.0,
          'L_user_4000Hz_dB': -10.0,
          'R_user_250Hz_dB': -10.0,
          'R_user_500Hz_dB': -10.0,
          'R_user_1000Hz_dB': -10.0,
          'R_user_2000Hz_dB': -10.0,
          'R_user_4000Hz_dB': -10.0,
        },
        icon: Icons.hearing,
      );

      // Set up the necessary stubs based on what TestPage actually calls
      when(mockProvider.getSoundTestById('test123')).thenReturn(mockSoundTest);
      when(mockProvider.updateSoundTest(any)).thenAnswer((_) => Future.value());

      // Stub AudioPlayer methods that might be called
      when(mockAudioPlayer.setPlayerMode(any))
          .thenAnswer((_) => Future.value());
      when(mockAudioPlayer.stop()).thenAnswer((_) => Future.value());
      when(mockAudioPlayer.release()).thenAnswer((_) => Future.value());
      when(mockAudioPlayer.setBalance(any)).thenAnswer((_) => Future.value());
      when(mockAudioPlayer.play(any,
              volume: anyNamed('volume'), balance: anyNamed('balance')))
          .thenAnswer((_) => Future.value());
      when(mockAudioPlayer.setVolume(any)).thenAnswer((_) => Future.value());
      when(mockAudioPlayer.setReleaseMode(any))
          .thenAnswer((_) => Future.value());
      when(mockAudioPlayer.onPlayerStateChanged)
          .thenAnswer((_) => const Stream.empty());
    });

    testWidgets('ear switching should change from left to right ear',
        (WidgetTester tester) async {
      // Create the widget under test with proper localization
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            TestAppLocalizationsDelegate(), // Use the test delegate
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
          ],
          home: TestPage(
            soundTestId: 'test123',
            soundTestName: 'Test Sound Test',
            soundTestProvider: mockProvider,
          ),
        ),
      );

      // Allow widget to build completely
      await tester.pumpAndSettle();

      // Get the state (we need to use State<TestPage> since _TestPageState is private)
      final state = tester.state<State<TestPage>>(find.byType(TestPage));

      // Set initial state using reflection since we can't access private state directly
      state.setState(() {
        // These fields are public in the state class
        (state as dynamic).current_ear = 'L';
        (state as dynamic).current_sound_stage = 6; // Last stage for left ear
        // Ensure ear_balance is initialized properly
        (state as dynamic).ear_balance = -1.0;
      });

      // Rebuild the widget with the modified state
      await tester.pump();

      // Act - Call updateCurrentEar method to trigger ear switching
      (state as dynamic).updateCurrentEar();

      // Rebuild again to reflect changes
      await tester.pump();

      // Assert - use dynamic casts to access state variables
      expect((state as dynamic).current_ear, equals('R'));
      expect((state as dynamic).ear_balance, equals(1.0)); // Full right balance
      expect((state as dynamic).current_sound_stage,
          equals(0)); // Reset to first stage
    });

    testWidgets(
        'ear switching should show completion dialog when right ear tests are done',
        (WidgetTester tester) async {
      // Create the widget under test with proper localization
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            TestAppLocalizationsDelegate(), // Use the test delegate
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
          ],
          home: TestPage(
            soundTestId: 'test123',
            soundTestName: 'Test Sound Test',
            soundTestProvider: mockProvider,
          ),
        ),
      );

      // Allow widget to build completely
      await tester.pumpAndSettle();

      // Get the state
      final state = tester.state<State<TestPage>>(find.byType(TestPage));

      // Set initial state for right ear's last stage
      state.setState(() {
        (state as dynamic).current_ear = 'R';
        (state as dynamic).current_sound_stage = 6; // Last stage for right ear
        // Ensure ear_balance is initialized properly
        (state as dynamic).ear_balance = 1.0;
        // Set test_completed to ensure dialog works
        (state as dynamic).test_completed = true;
      });

      // Rebuild the widget with the modified state
      await tester.pump();

      // Act - Call updateCurrentEar to trigger test completion
      (state as dynamic).updateCurrentEar();

      // Rebuild to show the dialog
      await tester.pumpAndSettle();

      // Assert - Check for dialog with localized text
      // We can't check for exact text since it's translated, so we'll check for the dialog itself
      expect(find.byType(AlertDialog), findsOneWidget);

      // We should find widgets with translated text from English translations
      // (assuming 'test_complete' in English is 'Test Completed')
      expect(find.textContaining('Test'), findsAtLeastNWidgets(1));

      // Check that ear balance was reset to center
      expect((state as dynamic).ear_balance, equals(0.0));
    });
  });
}
