import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:projects/features/sound_test/views/widgets/volume_control.dart';
import 'package:provider/provider.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';

@GenerateMocks([AudioPlayer, SoundTestProvider])
import 'volume_control_test.mocks.dart';

void main() {
  group('VolumeControl Widget Tests', () {
    late MockAudioPlayer mockPlayer;
    late MockSoundTestProvider mockProvider;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      mockProvider = MockSoundTestProvider();
    });

    testWidgets('should render volume slider', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: VolumeControl(
                player: mockPlayer,
                initialVolume: 0.5,
                onVolumeChanged: (volume) {},
              ),
            ),
          ),
        ),
      );

      // Find volume slider
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should update volume when slider is moved',
        (WidgetTester tester) async {
      // Arrange
      double capturedVolume = 0.0;
      when(mockPlayer.setVolume(any)).thenAnswer((_) async => 1);

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: VolumeControl(
                player: mockPlayer,
                initialVolume: 0.5,
                onVolumeChanged: (volume) {
                  capturedVolume = volume;
                },
              ),
            ),
          ),
        ),
      );

      // Find the slider
      final Finder sliderFinder = find.byType(Slider);

      // Get the slider width
      final Slider slider = tester.widget<Slider>(sliderFinder);
      expect(slider.value, 0.5); // Initial value

      // Simulate dragging the slider to 75%
      await tester.drag(sliderFinder, const Offset(100.0, 0.0));
      await tester.pumpAndSettle();

      // Verify the volume was set
      verify(mockPlayer.setVolume(any)).called(greaterThan(0));
      expect(capturedVolume, greaterThan(0.5));
    });

    testWidgets('should display volume icons based on value',
        (WidgetTester tester) async {
      // Build widget with low volume
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: VolumeControl(
                player: mockPlayer,
                initialVolume: 0.1,
                onVolumeChanged: (volume) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find all Icon widgets
      final iconFinder = find.byType(Icon);

      // Look for the third icon which should be the volume indicator (after minus and slider)
      expect(iconFinder, findsAtLeastNWidgets(3));

      // For low volume, verify we DONT have a volume_up icon
      final volumeUpFinder = find.byIcon(Icons.volume_up);
      expect(volumeUpFinder, findsNothing);

      // Recreate widget with high volume
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: VolumeControl(
                player: mockPlayer,
                initialVolume: 0.8,
                onVolumeChanged: (volume) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // For high volume, we should have a volume_up icon
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.volume_down), findsNothing);
    });

    testWidgets('should gradually increase volume',
        (WidgetTester tester) async {
      // Arrange
      final List<double> capturedVolumes = [];
      when(mockPlayer.setVolume(any)).thenAnswer((invocation) {
        capturedVolumes.add(invocation.positionalArguments[0] as double);
        return Future.value(1);
      });

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<SoundTestProvider>.value(
              value: mockProvider,
              child: VolumeControl(
                player: mockPlayer,
                initialVolume: 0.2,
                onVolumeChanged: (volume) {},
                incrementDuration: const Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      );

      // Find the increment button and press it
      final Finder incrementButton = find.byIcon(Icons.add);
      await tester.tap(incrementButton);

      // Wait for the animation to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify volumes were set in increments
      verify(mockPlayer.setVolume(any)).called(greaterThan(1));

      // Check that volumes gradually increased
      if (capturedVolumes.length > 1) {
        for (int i = 1; i < capturedVolumes.length; i++) {
          expect(capturedVolumes[i], greaterThan(capturedVolumes[i - 1]));
        }
      }
    });
  });
}
