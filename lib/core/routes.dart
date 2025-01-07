import 'package:flutter/material.dart';
import '../features/main_page/main_page.dart';
import '../features/presets/screens/preset1_page.dart';
import '../features/presets/screens/preset2_page.dart';
import '../features/presets/screens/presets_page.dart';
import '../features/settings/screens/settings_page.dart';

Map<String, WidgetBuilder> appRoutes(Map<String, dynamic> presetData) {
  return {
    '/': (BuildContext context) => MainPage(presetData: presetData),
    '/presets': (BuildContext context) => const PresetsPage(),
    '/preset1': (BuildContext context) => Preset1Page(presetData: presetData),
    '/preset2': (BuildContext context) => const Preset2Page(title: 'Preset 2'),
    '/settings': (BuildContext context) => const SettingsPage(),
  };
}
