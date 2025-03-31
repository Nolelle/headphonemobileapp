import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/presets/views/screens/preset_list_page.dart';
import '../features/settings/views/screens/settings_page.dart';
import '../features/sound_test/views/screens/sound_test_page.dart';
import '../features/presets/providers/preset_provider.dart';
import '../features/sound_test/providers/sound_test_provider.dart';
import '../features/bluetooth/providers/bluetooth_provider.dart';
import '../l10n/app_localizations.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, required Map<String, dynamic> presetData});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check Bluetooth connection when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BluetoothProvider>(context, listen: false);
      provider.checkBluetoothConnection();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final presetProvider = Provider.of<PresetProvider>(context);
    final appLocalizations = AppLocalizations.of(context);

    final List<Widget> pages = [
      Consumer<SoundTestProvider>(
        builder: (context, provider, _) => WillPopScope(
          onWillPop: () async =>
              false, // Prevent back button from popping this page
          child: SoundTestPage(
            soundTestProvider: provider,
          ),
        ),
      ),
      Consumer<PresetProvider>(
        builder: (context, provider, _) => PresetsListPage(
          presetProvider: provider,
        ),
      ),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.hearing),
            label: appLocalizations.translate('nav_hearing_test'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.headphones),
            label: appLocalizations.translate('nav_presets'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: appLocalizations.translate('nav_settings'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
