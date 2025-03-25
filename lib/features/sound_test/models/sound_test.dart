import 'package:flutter/material.dart';

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
      'soundTestData': soundTestData,
      'dateCreated': dateCreated.toIso8601String(),
      'name': name,
      // Using constant icon (Icons.hearing) to avoid tree-shaking issues with non-constant IconData
    };
  }

  factory SoundTest.fromJson(String id, Map<String, dynamic> json) {
    final rawData = json['soundTestData'] as Map<String, dynamic>;
    final soundTestData = <String, double>{};

    // Explicit conversion for each field
    soundTestData['L_band_1_dB'] =
        (rawData['L_band_1_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['L_band_2_dB'] =
        (rawData['L_band_2_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['L_band_3_dB'] =
        (rawData['L_band_3_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['L_band_4_dB'] =
        (rawData['L_band_4_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['L_band_5_dB'] =
        (rawData['L_band_5_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_1_dB'] =
        (rawData['R_band_1_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_2_dB'] =
        (rawData['R_band_2_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_3_dB'] =
        (rawData['R_band_3_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_4_dB'] =
        (rawData['R_band_4_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_5_dB'] =
        (rawData['R_band_5_dB'] as num?)?.toDouble() ?? 0.0;

    return SoundTest(
      id: id,
      name: json['name'] as String? ?? 'Audio Profile',
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      soundTestData: soundTestData,
      icon: Icons.hearing,
    );
  }

  factory SoundTest.defaultTest(String id) {
    return SoundTest(
      id: id,
      name: 'Default Audio Profile',
      dateCreated: DateTime.now(),
      soundTestData: {
        'L_band_1_dB': 0.0,
        'L_band_2_dB': 0.0,
        'L_band_3_dB': 0.0,
        'L_band_4_dB': 0.0,
        'L_band_5_dB': 0.0,
        'R_band_1_dB': 0.0,
        'R_band_2_dB': 0.0,
        'R_band_3_dB': 0.0,
        'R_band_4_dB': 0.0,
        'R_band_5_dB': 0.0,
      },
      icon: Icons.hearing,
    );
  }
}
