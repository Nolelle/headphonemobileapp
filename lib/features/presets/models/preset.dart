// lib/models/preset.dart
import 'package:flutter/foundation.dart';

class Preset {
  final String id;
  final String name;
  final DateTime dateCreated;
  final Map<String, dynamic> presetData;

  const Preset({
    required this.id,
    required this.name,
    required this.dateCreated,
    required this.presetData,
  });

  // Convert Preset to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'presetData': presetData,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  // Create Preset from JSON Map
  factory Preset.fromJson(String presetId, Map<String, dynamic> json) {
    return Preset(
      id: presetId,
      name: json['name'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      presetData: Map<String, dynamic>.from(json['presetData'] as Map),
    );
  }
}
