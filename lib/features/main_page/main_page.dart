import 'package:flutter/material.dart';
import '../presets/screens/presets_page.dart';
import '../settings/screens/settings_page.dart';
import './sound_test.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> presetData;

  const MainPage({super.key, required this.presetData});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1; //starting on the 'Presets' page

  final List<String> _titles = [
    'Sound Test',
    'Presets',
    'Settings',
  ];

  late final List<Widget> _pages = [
    const SoundTestPage(),
    PresetsPage(presetData: widget.presetData),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        title: Align(
          alignment: Alignment.center,
          child: Text(
            _titles[_currentIndex], // Dynamic title based on the current page
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.volume_up), label: 'Sound Test'),
          BottomNavigationBarItem(
              icon: Icon(Icons.equalizer_rounded), label: 'Presets'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
