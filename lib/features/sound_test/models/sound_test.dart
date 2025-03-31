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
    final rawData = json['soundTestData'] as Map<String, dynamic>;
    final soundTestData = <String, double>{};

    // Explicit conversion for each field
    soundTestData['L_user_250Hz_dB'] =
        (rawData['L_user_250Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['L_user_500Hz_dB'] =
        (rawData['L_user_500Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['L_user_1000Hz_dB'] =
        (rawData['L_user_1000Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['L_user_2000Hz_dB'] =
        (rawData['L_user_2000Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['L_user_4000Hz_dB'] =
        (rawData['L_user_4000Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['R_user_250Hz_dB'] =
        (rawData['R_user_250Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['R_user_500Hz_dB'] =
        (rawData['R_user_500Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['R_user_1000Hz_dB'] =
        (rawData['R_user_1000Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['R_user_2000Hz_dB'] =
        (rawData['R_user_2000Hz_dB'] as num?)?.toDouble() ?? -10.0;
    soundTestData['R_user_4000Hz_dB'] =
        (rawData['R_user_4000Hz_dB'] as num?)?.toDouble() ?? -10.0;

    return SoundTest(
      id: id,
      name: json['name'] as String? ?? 'Audio Profile',
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      soundTestData: soundTestData,
      icon: Icons.hearing,
    );
  }

  factory SoundTest.defaultTest(String id, {BuildContext? context}) {
    // Using baseline values around 10 dB which represents good hearing
    // Lower values (closer to 0) represent better hearing
    const baselineValue = -10.0; // This will convert to about 10 dB in the UI

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
