import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:projects/features/sound_test/views/screens/test_page.dart';
import 'package:mockito/annotations.dart';
import 'package:audioplayers/audioplayers.dart';

@GenerateMocks([AudioPlayer, SoundTestProvider])
import 'ear_switching_test.mocks.dart';

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

    setUp(() {
      mockProvider = MockSoundTestProvider();
    });

    testWidgets('ear switching should change from left to right ear',
        (WidgetTester tester) async {
      // Create the widget under test
      await tester.pumpWidget(
        MaterialApp(
          home: TestPage(
            soundTestId: 'test123',
            soundTestName: 'Test Sound Test',
            soundTestProvider: mockProvider,
          ),
        ),
      );

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
      // Create the widget under test
      await tester.pumpWidget(
        MaterialApp(
          home: TestPage(
            soundTestId: 'test123',
            soundTestName: 'Test Sound Test',
            soundTestProvider: mockProvider,
          ),
        ),
      );

      // Get the state
      final state = tester.state<State<TestPage>>(find.byType(TestPage));

      // Set initial state for right ear's last stage
      state.setState(() {
        (state as dynamic).current_ear = 'R';
        (state as dynamic).current_sound_stage = 6; // Last stage for right ear
        // Ensure ear_balance is initialized properly
        (state as dynamic).ear_balance = 1.0;
      });

      // Rebuild the widget with the modified state
      await tester.pump();

      // Act - Call updateCurrentEar to trigger test completion
      (state as dynamic).updateCurrentEar();

      // Rebuild to show the dialog
      await tester.pumpAndSettle();

      // Assert - Test completion dialog should be shown
      expect(find.text('Test Completed'), findsOneWidget);
      expect(find.text('The test has been recorded successfully.'),
          findsOneWidget);
      expect((state as dynamic).ear_balance,
          equals(0.0)); // Balance returned to center
    });
  });
}
