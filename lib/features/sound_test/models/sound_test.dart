import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class SoundTest {
  final String id;
  final String name;
  final DateTime dateCreated;
  final Map<String, double> soundTestData;
  final IconData? icon;

  const SoundTest({
    required this.id,
    required this.dateCreated,
    required this.soundTestData,
    this.name = 'Audio Profile',
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateCreated': dateCreated.toIso8601String(),
      'soundTestData': {
        'L_user_250Hz_dB': soundTestData['L_user_250Hz_dB'],
        'L_user_500Hz_dB': soundTestData['L_user_500Hz_dB'],
        'L_user_1000Hz_dB': soundTestData['L_user_1000Hz_dB'],
        'L_user_2000Hz_dB': soundTestData['L_user_2000Hz_dB'],
        'L_user_4000Hz_dB': soundTestData['L_user_4000Hz_dB'],
        'R_user_250Hz_dB': soundTestData['R_user_250Hz_dB'],
        'R_user_500Hz_dB': soundTestData['R_user_500Hz_dB'],
        'R_user_1000Hz_dB': soundTestData['R_user_1000Hz_dB'],
        'R_user_2000Hz_dB': soundTestData['R_user_2000Hz_dB'],
        'R_user_4000Hz_dB': soundTestData['R_user_4000Hz_dB'],
      },
    };
  }

  factory SoundTest.fromJson(String id, Map<String, dynamic> json) {
    // Safely handle the soundTestData which might be null or not a valid map
    Map<String, dynamic>? rawData;
    try {
      rawData = json['soundTestData'] as Map<String, dynamic>?;
    } catch (e) {
      rawData = null;
    }

    rawData = rawData ?? {}; // Default to empty map if null
    final soundTestData = <String, double>{};

    // Explicit conversion for each field with fallback
    soundTestData['L_user_250Hz_dB'] =
        (rawData['L_user_250Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['L_user_500Hz_dB'] =
        (rawData['L_user_500Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['L_user_1000Hz_dB'] =
        (rawData['L_user_1000Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['L_user_2000Hz_dB'] =
        (rawData['L_user_2000Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['L_user_4000Hz_dB'] =
        (rawData['L_user_4000Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['R_user_250Hz_dB'] =
        (rawData['R_user_250Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['R_user_500Hz_dB'] =
        (rawData['R_user_500Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['R_user_1000Hz_dB'] =
        (rawData['R_user_1000Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['R_user_2000Hz_dB'] =
        (rawData['R_user_2000Hz_dB'] as num?)?.toDouble() ?? 15.0;
    soundTestData['R_user_4000Hz_dB'] =
        (rawData['R_user_4000Hz_dB'] as num?)?.toDouble() ?? 15.0;

    return SoundTest(
      id: id,
      name: json['name'] as String? ?? 'Audio Profile',
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      soundTestData: soundTestData,
      icon: Icons.hearing,
    );
  }

  factory SoundTest.defaultTest(String id, {BuildContext? context}) {
    // Using baseline values in the middle of normal hearing range (0-30 dB)
    // A value of 15 dB is comfortably in the normal hearing range
    // Lower values (closer to 0) represent better hearing
    const baselineValue =
        15.0; // This will show as 15 dB in the UI, in the normal hearing range

    String profileName = 'Default Audio Profile';
    if (context != null) {
      final appLocalizations = AppLocalizations.of(context);
      profileName = appLocalizations.translate('default_audio_profile');
    }

    return SoundTest(
      id: id,
      name: profileName,
      dateCreated: DateTime.now(),
      soundTestData: {
        'L_user_250Hz_dB': baselineValue,
        'L_user_500Hz_dB': baselineValue,
        'L_user_1000Hz_dB': baselineValue,
        'L_user_2000Hz_dB': baselineValue,
        'L_user_4000Hz_dB': baselineValue,
        'R_user_250Hz_dB': baselineValue,
        'R_user_500Hz_dB': baselineValue,
        'R_user_1000Hz_dB': baselineValue,
        'R_user_2000Hz_dB': baselineValue,
        'R_user_4000Hz_dB': baselineValue,
      },
      icon: Icons.hearing,
    );
  }
}
