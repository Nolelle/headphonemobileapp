import 'package:flutter/material.dart';
import 'package:projects/features/sound_test/providers/sound_test_provider.dart';
import 'package:provider/provider.dart';
import '../features/presets/views/screens/preset_list_page.dart';
import '../features/settings/views/screens/settings_page.dart';
import '../features/sound_test/views/screens/sound_test_page.dart';
import '../features/presets/providers/preset_provider.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import '../features/bluetooth/views/screens/bluetooth_settings_page.dart';
import '../features/bluetooth/providers/bluetooth_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check Bluetooth connection when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BluetoothProvider>(context, listen: false);
      provider.checkBluetoothConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    final presetProvider = Provider.of<PresetProvider>(context);

    final List<Widget> pages = [
      Consumer<SoundTestProvider>(
        builder: (context, provider, _) => SoundTestPage(
          soundTestProvider: provider,
        ),
      ),
      PresetsListPage(
        presetProvider: presetProvider,
      ),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.hearing),
            label: 'Hearing Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: 'Presets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color.fromRGBO(82, 56, 110, 1.0),
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 8,
      ),
    );
  }
}
