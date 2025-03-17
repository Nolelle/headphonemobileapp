import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';

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
    late MockAudioPlayer mockPlayer;
    late MockSoundTestProvider mockProvider;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      mockProvider = MockSoundTestProvider();
    });

    testWidgets('should display ear switching UI correctly',
        (WidgetTester tester) async {
      // Build ear switching widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: EarSwitchWidget(
                player: mockPlayer,
                initialBalance: 0.0, // Start with both ears
                onBalanceChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify initial state shows both ears
      expect(find.text('Current Ear: Both'), findsOneWidget);
      expect(find.text('Left Ear'), findsOneWidget);
      expect(find.text('Both Ears'), findsOneWidget);
      expect(find.text('Right Ear'), findsOneWidget);
    });

    testWidgets('should switch to left ear when left ear button is tapped',
        (WidgetTester tester) async {
      // Arrange
      double capturedBalance = 0.0;
      when(mockPlayer.setBalance(any)).thenAnswer((_) async => 1);

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: EarSwitchWidget(
                player: mockPlayer,
                initialBalance: 0.0,
                onBalanceChanged: (balance) {
                  capturedBalance = balance;
                },
              ),
            ),
          ),
        ),
      );

      // Act - tap left ear button
      await tester.tap(find.text('Left Ear'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Current Ear: Left'), findsOneWidget);
      verify(mockPlayer.setBalance(-1.0)).called(greaterThan(0));
      expect(capturedBalance, -1.0);
    });

    testWidgets('should switch to right ear when right ear button is tapped',
        (WidgetTester tester) async {
      // Arrange
      double capturedBalance = 0.0;
      when(mockPlayer.setBalance(any)).thenAnswer((_) async => 1);

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: EarSwitchWidget(
                player: mockPlayer,
                initialBalance: 0.0,
                onBalanceChanged: (balance) {
                  capturedBalance = balance;
                },
              ),
            ),
          ),
        ),
      );

      // Act - tap right ear button
      await tester.tap(find.text('Right Ear'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Current Ear: Right'), findsOneWidget);
      verify(mockPlayer.setBalance(1.0)).called(greaterThan(0));
      expect(capturedBalance, 1.0);
    });

    testWidgets('should switch back to both ears from left ear',
        (WidgetTester tester) async {
      // Arrange
      double capturedBalance = -1.0; // Start with left ear
      when(mockPlayer.setBalance(any)).thenAnswer((_) async => 1);

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: EarSwitchWidget(
                player: mockPlayer,
                initialBalance: -1.0, // Start with left ear
                onBalanceChanged: (balance) {
                  capturedBalance = balance;
                },
              ),
            ),
          ),
        ),
      );

      // Verify we start with left ear
      expect(find.text('Current Ear: Left'), findsOneWidget);

      // Act - tap both ears button
      await tester.tap(find.text('Both Ears'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Current Ear: Both'), findsOneWidget);
      verify(mockPlayer.setBalance(0.0)).called(greaterThan(0));
      expect(capturedBalance, 0.0);
    });

    testWidgets('should highlight the active ear button',
        (WidgetTester tester) async {
      // Mock player setup
      when(mockPlayer.setBalance(any)).thenAnswer((_) async => 1);

      // Build widget with left ear selected
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: EarSwitchWidget(
                player: mockPlayer,
                initialBalance: -1.0, // Start with left ear
                onBalanceChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify the left ear button is highlighted initially
      final leftButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Left Ear'));
      expect(
        (leftButton.style?.backgroundColor as WidgetStatePropertyAll?)?.value,
        Colors.blue,
      );

      // Switch to right ear
      await tester.tap(find.text('Right Ear'));
      await tester.pumpAndSettle();

      // Verify the right ear button is now highlighted
      final rightButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Right Ear'));
      expect(
        (rightButton.style?.backgroundColor as WidgetStatePropertyAll?)?.value,
        Colors.blue,
      );
    });
  });
}
