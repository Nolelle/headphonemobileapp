import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:projects/core/utils/bluetooth_manager.dart';
import '../features/presets/views/screens/preset_list_page.dart';
import '../features/settings/views/settings_page.dart';
import '../features/sound_test/views/sound_test_page.dart';
import '../features/presets/providers/preset_provider.dart';
import 'package:provider/provider.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> presetData;

  const MainNavigation({
    super.key,
    required this.presetData,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1; // Changed to 1 to make Presets the middle tab
  bool bluetoothDeviceConnected = false;
  final BluetoothManager _bluetoothManager = BluetoothManager();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const SoundTestPage(),
      Consumer<PresetProvider>(builder: (context, provider, _) => PresetsListPage(presetProvider: provider)),
      const SettingsPage(),
    ];
    _checkBluetoothConnection();
  }

  // Checking Bluetooth connection state using BluetoothManager
  Future<void> _checkBluetoothConnection() async {
    try {
      // Check connected devices using BluetoothManager
      await _bluetoothManager.checkConnectedDevices();

      // Update UI based on connection status
      setState(() {
        bluetoothDeviceConnected = _bluetoothManager.bluetoothDeviceConnected;
      });
    } catch (e) {
      print("Error checking Bluetooth connection: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bluetoothDeviceConnected) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _getTitle(),
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note_rounded),
              label: 'Sound Test',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hearing_rounded),
              label: 'Presets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromRGBO(133, 86, 169, 1.00),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.shifting,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
        ),
      );
    } else {
      // No Bluetooth device connected
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "You have no Bluetooth device connected!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  var openAppResult = await LaunchApp.openApp(
                    androidPackageName: "com.android.settings",
                  );
                },
                child: const Text("Go to Settings"),
              ),

            ],
          ),
        ),
      );
    }
  }

  // Handle navigation bar item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Sound Test';
      case 1:
        return 'My Presets';
      case 2:
        return 'Settings';
      default:
        return 'My Presets';
    }
  }
}
