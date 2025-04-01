import 'package:flutter/material.dart';
import '../features/presets/repositories/preset_repository.dart';
import '../features/presets/providers/preset_provider.dart';
import '../features/presets/views/screens/preset_list_page.dart';
import '../features/presets/views/screens/preset_page.dart';
import '../core/main_nav.dart';
import 'package:provider/provider.dart';
import '../features/sound_test/providers/sound_test_provider.dart'; // Import SoundTestProvider
import '../features/sound_test/repositories/sound_test_repository.dart'; // Import SoundTestRepository

Map<String, Widget Function(BuildContext)> appRoutes(
    Map<String, dynamic> presetData) {
  // Create a PresetProvider instance to be used across the app
  final presetProvider = PresetProvider(PresetRepository())..fetchPresets();
  // Create a SoundTestProvider instance to be used across the app
  final soundTestProvider = SoundTestProvider(SoundTestRepository())..fetchSoundTests();

  return {
    // Root route with MultiProvider setup
    '/': (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: presetProvider),
        ChangeNotifierProvider.value(value: soundTestProvider),
      ],
      child: MainNavigation(),
    ),

    // Presets list route
    '/presets': (context) => Consumer<PresetProvider>(
      builder: (context, provider, _) => PresetsListPage(
        presetProvider: provider,
      ),
    ),

    // Individual preset route with dynamic navigation
    '/preset': (context) {
      final args =
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PresetPage(
        presetId: args['presetId'] as String,
        presetName: args['presetName'] as String,
        presetProvider: Provider.of<PresetProvider>(context),
      );
    },
  };
}