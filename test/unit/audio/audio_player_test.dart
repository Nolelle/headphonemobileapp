import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AudioPlayer])
import 'audio_player_test.mocks.dart';

void main() {
  group('AudioPlayer Tests', () {
    late MockAudioPlayer audioPlayer;

    setUp(() {
      audioPlayer = MockAudioPlayer();
    });

    test('play should call play with correct parameters', () async {
      // Arrange
      when(audioPlayer.play(any,
              volume: anyNamed('volume'), balance: anyNamed('balance')))
          .thenAnswer((_) async => 1);

      // Act
      await audioPlayer.play(
        AssetSource('audio/1000Hz.wav'),
        volume: 0.5,
        balance: 0.0,
      );

      // Assert
      verify(audioPlayer.play(any, volume: 0.5, balance: 0.0)).called(1);
    });

    test('pause should pause playback', () async {
      // Arrange
      when(audioPlayer.pause()).thenAnswer((_) async => 1);

      // Act
      await audioPlayer.pause();

      // Assert
      verify(audioPlayer.pause()).called(1);
    });

    test('resume should resume playback', () async {
      // Arrange
      when(audioPlayer.resume()).thenAnswer((_) async => 1);

      // Act
      await audioPlayer.resume();

      // Assert
      verify(audioPlayer.resume()).called(1);
    });

    test('stop should stop playback', () async {
      // Arrange
      when(audioPlayer.stop()).thenAnswer((_) async => 1);

      // Act
      await audioPlayer.stop();

      // Assert
      verify(audioPlayer.stop()).called(1);
    });

    test('setVolume should set the correct volume', () async {
      // Arrange
      when(audioPlayer.setVolume(any)).thenAnswer((_) async => 1);

      // Act
      await audioPlayer.setVolume(0.7);

      // Assert
      verify(audioPlayer.setVolume(0.7)).called(1);
    });

    test('setBalance should set the correct balance', () async {
      // Arrange
      when(audioPlayer.setBalance(any)).thenAnswer((_) async => 1);

      // Act
      await audioPlayer.setBalance(-1.0); // Left ear

      // Assert
      verify(audioPlayer.setBalance(-1.0)).called(1);
    });

    test('release should release resources', () async {
      // Arrange
      when(audioPlayer.release()).thenAnswer((_) async => 1);

      // Act
      await audioPlayer.release();

      // Assert
      verify(audioPlayer.release()).called(1);
    });
  });
}
