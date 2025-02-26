import 'package:flutter/material.dart';

class SoundTest {
  final String id;
  final String name;
  final DateTime dateCreated;
  final Map<String, dynamic> soundTestData;
  //this is for customization and identification purposes only we can remove this if needed
  final IconData icon; // Add this field

  const SoundTest({
    required this.id,
    required this.name,
    required this.dateCreated,
    required this.soundTestData,
    //this is for customization and identification purposes only we can remove this if needed
    this.icon = Icons.home, // Default icon
  });

  // Convert SoundTest to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'soundTestData': soundTestData,
      'dateCreated': dateCreated.toIso8601String(),
      'icon': icon.codePoint, // Save the icon as a code point
    };
  }

  // Create SoundTest from JSON Map
  factory SoundTest.fromJson(String presetId, Map<String, dynamic> json) {
    return SoundTest(
      id: presetId,
      name: json['name'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      soundTestData: Map<String, dynamic>.from(json['soundTestData'] as Map),
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'), // Load the icon
    );
  }
}