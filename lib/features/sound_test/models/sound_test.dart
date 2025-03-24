class SoundTest {
  final String id;
  final DateTime dateCreated;
  final Map<String, double> soundTestData;

  const SoundTest({
    required this.id,
    required this.dateCreated,
    required this.soundTestData,
  });

  Map<String, dynamic> toJson() {
    return {
      'soundTestData': soundTestData,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  factory SoundTest.fromJson(String id, Map<String, dynamic> json) {
    final rawData = json['soundTestData'] as Map<String, dynamic>;
    final soundTestData = <String, double>{};

    // Explicit conversion for each field
    soundTestData['L_band_1_dB'] = (rawData['L_band_1_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['L_band_2_dB'] = (rawData['L_band_2_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['L_band_3_dB'] = (rawData['L_band_3_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['L_band_4_dB'] = (rawData['L_band_4_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['L_band_5_dB'] = (rawData['L_band_5_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_1_dB'] = (rawData['R_band_1_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_2_dB'] = (rawData['R_band_2_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_3_dB'] = (rawData['R_band_3_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_4_dB'] = (rawData['R_band_4_dB'] as num?)?.toDouble() ?? 0.0;
    soundTestData['R_band_5_dB'] = (rawData['R_band_5_dB'] as num?)?.toDouble() ?? 0.0;

    return SoundTest(
      id: id,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      soundTestData: soundTestData,
    );
  }

  factory SoundTest.defaultTest(String id) {
    return SoundTest(
      id: id,
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
    );
  }
}