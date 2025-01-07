import 'dart:convert'; // For JSON decoding
import 'package:flutter/services.dart' show rootBundle; // For rootBundle

Future<Map<String, dynamic>> loadJson() async {
  try {
    final String jsonString =
        await rootBundle.loadString('assets/preset_1_prototype.json');
    return json.decode(jsonString); // Return the parsed JSON data as a Map
  } catch (e) {
    print('Error loading or parsing JSON: $e');
    return {}; // Return an empty map in case of error
  }
}
