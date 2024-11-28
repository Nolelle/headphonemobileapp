import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  int _currentIndex = 1; //starting on the 'Presets' page

  //the pages
  final List<Widget> _pages = [
    const SoundTestPage(),//this will be empty
    const PresetsPage(),
    const SettingsPage(),//this will be empty
  ];

  final List<String> _titles = [
    'Sound Test',
    'Presets',
    'Settings',
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
          BottomNavigationBarItem(icon: Icon(Icons.volume_up), label: 'Sound Test'),
          BottomNavigationBarItem(icon: Icon(Icons.equalizer_rounded), label: 'Presets'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class PresetsPage extends StatefulWidget {
  const PresetsPage({super.key});

  @override
  _PresetsPageState createState() => _PresetsPageState();
}
class _PresetsPageState extends State<PresetsPage> {
  int selected_button = 0; //0 is for preset 1, and 1 is for preset 2

  final Color selected_button_color = const Color.fromRGBO(93, 59, 129, 1.00);
  final Color unselected_button_color = const Color.fromRGBO(133, 86, 169, 1.00);

  @override
  Widget build(BuildContext context) {
    //temp headphones attributes
    const String HEADPHONE_NAME = "John's Headphones";
    const int BATTERY_LEVEL = 73;
    const bool IS_CONNECTED = true;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //headphone name
            const Text(
                HEADPHONE_NAME,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )
            ),
            const SizedBox(height: 16),
            //battery level
            const Text(
              'Battery: $BATTERY_LEVEL%',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            //connection status
            const Text(
              'Connection Status:',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
            const Text(
              IS_CONNECTED ? "Connected" : "Not Connected",
              style: TextStyle(
                fontSize: 20,
                color: IS_CONNECTED ? Colors.green : Colors.red,
              ),
            ),
            //preset 1
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selected_button = 0; // Select Preset 1
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('\'Preset 1\' Successfully Sent To Device!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selected_button == 0 ? selected_button_color : unselected_button_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Preset 1',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Preset2Page()),
                          );
                        },
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selected_button = 1; // Select Preset 2
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('\'Preset 2\' Successfully Sent To Device!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selected_button == 1 ? selected_button_color : unselected_button_color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Preset 2',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Preset2Page()),
                          );
                        },
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//BALJOT WORK HERE
//don't actually work on all the pages, just do the 'Preset 1' page and duplicate it to 'Preset 2' page
class SoundTestPage extends StatelessWidget {
  const SoundTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child:
      Text(
        '¯\\_(ツ)_/¯',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(133, 86, 169, 1.00),
        ),
      ),
    );
  }
}
class Preset1Page extends StatelessWidget {//will not have the bottom bar, only back button
  const Preset1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Preset 1',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Custom behavior for back button
          },
        ),
      ),
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: const Text('Nothing is here!'),
    );
  }
}
class Preset2Page extends StatelessWidget {//will not have the bottom bar, only back button
  const Preset2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Preset 2',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Custom behavior for back button
          },
        ),
      ),
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: const Text('Nothing is here!'),
    );
  }
}
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child:
        Text(
          '¯\\_(ツ)_/¯',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(133, 86, 169, 1.00),
          ),
        ),
    );
  }
}
