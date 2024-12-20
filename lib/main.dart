import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON decoding
import 'package:flutter/services.dart' show rootBundle; // For rootBundle
import 'dart:io'; // For File I/O
import 'package:path_provider/path_provider.dart'; // To get the app's document directory


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure async code can run in main()
  final presetData = await loadJson(); // Load the JSON data asynchronously
  runApp(MyApp(presetData: presetData)); // Pass the data to the app
}

Future<Map<String, dynamic>> loadJson() async {
  try {
    final String jsonString = await rootBundle.loadString('assets/preset_1_prototype.json');
    return json.decode(jsonString); // Return the parsed JSON data as a Map
  } catch (e) {
    print('Error loading or parsing JSON: $e');
    return {}; // Return an empty map in case of error
  }
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> presetData; // This holds the JSON data

  const MyApp({super.key, required this.presetData}); // Constructor for presetData

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainPage(presetData: presetData), // Pass the presetData directly
    );
  }
}

class MainPage extends StatefulWidget {
  final Map<String, dynamic> presetData;

  const MainPage({super.key, required this.presetData});

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
                            MaterialPageRoute(builder: (context) => Preset1Page(presetData: {},)),
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
                            MaterialPageRoute(builder: (context) => const Preset2Page(title: '',)),
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
}//we leave this empty, nothing goes here!

class Preset1Page extends StatefulWidget {
  late Map<String, dynamic> presetData;

  Preset1Page({super.key, required this.presetData});

  @override
  _Preset1PageState createState() => _Preset1PageState();
}
class _Preset1PageState extends State<Preset1Page> {//will not have the bottom bar, only back button
  double db_valueOV = 0.0;
  double db_valueSB_BS = 0.0;
  double db_valueSB_MRS = 0.0;
  double db_valueSB_TS = 0.0;

  //its either true = on, or false = off
  bool reduce_background_noise = false;
  bool reduce_wind_noise = false;
  bool soften_sudden_noise = false;

  // A method to load data from the file
  Future<Map<String, dynamic>> loadPresetData() async {
    final directory = await getApplicationDocumentsDirectory();
    print('Saving file at: ${directory.path}');
    final file = File('${directory.path}/preset_1_prototype.json');

    if (await file.exists()) {
      String jsonData = await file.readAsString();
      return jsonDecode(jsonData);  // Return decoded JSON as Map
    } else {
      return {};  // Return an empty map if the file doesn't exist
    }
  }

  // Method to update preset data from loaded JSON
  void _updatePresetData() {
    final presetData = widget.presetData['preset1']?['presetData']?[0];

    if (presetData != null) {
      setState(() {
        db_valueOV = presetData['db_valueOV'];
        db_valueSB_BS = presetData['db_valueSB_BS'];
        db_valueSB_MRS = presetData['db_valueSB_MRS'];
        db_valueSB_TS = presetData['db_valueSB_TS'];

        reduce_background_noise = presetData['reduce_background_noise'] ?? false;
        reduce_wind_noise = presetData['reduce_wind_noise'] ?? false;
        soften_sudden_noise = presetData['soften_sudden_noise'] ?? false;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    loadPresetData().then((data) {
      // Assign the loaded data to widget.presetData or another local variable
      widget.presetData = data;
      _updatePresetData();  // Update UI with loaded data
    });
  }

  // Method to save preset data to a file
  Future<void> _savePresetData() async {
    try {
      // Ensure presetData is initialized
      if (widget.presetData == null) {
        print('presetData is null!');
        return; // Exit if presetData is null
      }

      // Ensure 'preset1' and its 'presetData' are initialized
      if (widget.presetData['preset1'] == null) {
        print('preset1 is null, initializing preset1...');
        widget.presetData['preset1'] = {'presetData': [{}]};
      }

      // Ensure 'presetData' is initialized within 'preset1'
      if (widget.presetData['preset1']['presetData'] == null) {
        print('presetData is null, initializing presetData...');
        widget.presetData['preset1']['presetData'] = [{}];
      }

      // Update the presetData values
      widget.presetData['preset1']['presetData'][0] = {
        'db_valueOV': db_valueOV,
        'db_valueSB_BS': db_valueSB_BS,
        'db_valueSB_MRS': db_valueSB_MRS,
        'db_valueSB_TS': db_valueSB_TS,
        'reduce_background_noise': reduce_background_noise,
        'reduce_wind_noise': reduce_wind_noise,
        'soften_sudden_noise': soften_sudden_noise,
      };

      String updatedJsonData = jsonEncode(widget.presetData);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/preset_1_prototype.json');
      print('Saving file at: ${file.path}');

      // Writing to the file
      await file.writeAsString(updatedJsonData);
      print('File saved successfully!');
    } catch (e) {
      print('Error saving preset data: $e');
    }
  }
  // Method to reset the preset data (to stand in for the delete method used in the final version of the app)
  void _resetPresetData() {
    setState(() {
      // Reset all preset data values to default values
      db_valueOV = 0.0;
      db_valueSB_BS = 0.0;
      db_valueSB_MRS = 0.0;
      db_valueSB_TS = 0.0;

      reduce_background_noise = false;
      reduce_wind_noise = false;
      soften_sudden_noise = false;
    });

    // Optionally, reset the data in the `widget.presetData` as well
    if (widget.presetData != null && widget.presetData['preset1'] != null) {
      widget.presetData['preset1']['presetData'][0] = {
        'db_valueOV': db_valueOV,
        'db_valueSB_BS': db_valueSB_BS,
        'db_valueSB_MRS': db_valueSB_MRS,
        'db_valueSB_TS': db_valueSB_TS,
        'reduce_background_noise': reduce_background_noise,
        'reduce_wind_noise': reduce_wind_noise,
        'soften_sudden_noise': soften_sudden_noise,
      };
      // Save the reset data (if needed)
      _savePresetData();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preset data reset successfully!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Preset 1 [NEW]',
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          //this will be for the header
          children: [
            //'Overall Volume' container
            Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  //'Overall Volume' header
                  const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.volume_up,
                          color: Colors.black,
                          size: 30,
                        ),
                        Text(
                          ' Overall Volume',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                  ),
                  //'Softer' -> 'Louder' bar
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Softer'),
                      Text('Louder'),
                    ],
                  ),
                  //constant sliding bar
                  Slider(
                    value: db_valueOV,
                    onChanged: (new_value) {
                      setState(() {
                        db_valueOV = new_value;
                      });
                    },
                    min: -90.0, // Minimum slider value
                    max: 90.0, // Maximum slider value
                    divisions: 18, // Optional, creates steps
                    label: '${db_valueOV.toStringAsFixed(1)} dB',
                  ),
                  //dB level text
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${db_valueOV.toStringAsFixed(1)} dB',
                    ),
                  ),
                ],
              ),
            ),
            //'Sound Balance' container
            Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  //'Sound Balance' header
                  const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.earbuds_rounded,
                          color: Colors.black,
                          size: 30,
                        ),
                        Text(
                          ' Sound Balance',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                  ),

                  //'Bass Sounds' slider
                  Container(
                    child: Column(
                      children: [
                        //'Bass Sounds' -> 'Louder' bar
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bass Sounds'),
                            Text('Louder'),
                          ],
                        ),
                        //constant sliding bar
                        Slider(
                          value: db_valueSB_BS,
                          onChanged: (new_value) {
                            setState(() {
                              db_valueSB_BS = new_value;
                            });
                          },
                          min: -90.0, // Minimum slider value
                          max: 90.0, // Maximum slider value
                          divisions: 18, // Optional, creates steps
                          label: '${db_valueSB_BS.toStringAsFixed(1)} dB',
                        ),
                        //enhancing deep sounds text
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enhances deep sounds like background noise and speech fundamentals\n',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //'Mid-Range Sounds' slider
                  Container(
                    child: Column(
                      children: [
                        //'Mid-Range Sounds' -> 'Louder' bar
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mid-Range Sounds'),
                            Text('Louder'),
                          ],
                        ),
                        //constant sliding bar
                        Slider(
                          value: db_valueSB_MRS,
                          onChanged: (new_value) {
                            setState(() {
                              db_valueSB_MRS = new_value;
                            });
                          },
                          min: -90.0, // Minimum slider value
                          max: 90.0, // Maximum slider value
                          divisions: 18, // Optional, creates steps
                          label: '${db_valueSB_MRS.toStringAsFixed(1)} dB',
                        ),
                        //enhancing main speech text
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enhances main speech sounds and voices\n',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //'Treble Sounds' slider
                  Container(
                    child: Column(
                      children: [
                        //'Softer' -> 'Louder' bar
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Treble Sounds'),
                            Text('Louder'),
                          ],
                        ),
                        //constant sliding bar
                        Slider(
                          value: db_valueSB_TS,
                          onChanged: (new_value) {
                            setState(() {
                              db_valueSB_TS = new_value;
                            });
                          },
                          min: -90.0, // Minimum slider value
                          max: 90.0, // Maximum slider value
                          divisions: 18, // Optional, creates steps
                          label: '${db_valueSB_TS.toStringAsFixed(1)} dB',
                        ),
                        //dB level text
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enhances clarity and crisp sounds like consonants\n',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //'Sound Enhancement' container
            Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  //'Sound Enhancement' header
                  const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_sharp,
                          color: Colors.black,
                          size: 30,
                        ),
                        Text(
                          ' Sound Enhancement',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                  ),
                  //reduce background noise section
                  Row(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reduce Background Noise',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Minimize constant background sounds',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Switch(
                            value: reduce_background_noise,
                            onChanged: (value) {
                              setState(() {
                                reduce_background_noise = value; // Update the toggle state
                              });
                            },
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                            inactiveTrackColor: Colors.grey,
                          );
                        },
                      )
                    ],
                  ),
                  //reduce wind noise section
                  Row(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reduce Wind Noise',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Helps in outdoor environments',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Switch(
                            value: reduce_wind_noise,
                            onChanged: (value) {
                              setState(() {
                                reduce_wind_noise = value; // Update the toggle state
                              });
                            },
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                            inactiveTrackColor: Colors.grey,
                          );
                        },
                      )
                    ],
                  ),
                  //soften sudden sounds section
                  Row(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Soften Sudden Sounds',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Reduces unexpected loud noises',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Switch(
                            value: soften_sudden_noise,
                            onChanged: (value) {
                              setState(() {
                                soften_sudden_noise = value; // Update the toggle state
                              });
                            },
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                            inactiveTrackColor: Colors.grey,
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            //'Save' and 'Delete' buttons container
            Container(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //save
                  ElevatedButton(
                      onPressed: () async {
                        await _savePresetData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('\'Preset 1\' Successfully Saved!'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00), // Button background color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded),
                          Text(
                            " Save",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      )

                  ),
                  //delete
                  ElevatedButton(
                    onPressed: () async {
                      _resetPresetData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('\'Preset 1\' Successfully Deleted!'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      Navigator.pop(context); // Custom behavior for back button
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00), // Button background color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_forever),
                        Text(
                          " Delete",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    )

                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Preset2Page extends StatefulWidget {
  const Preset2Page({super.key, required this.title});
  final String title;
  @override
  _Preset2PageState createState() => _Preset2PageState();
}
class _Preset2PageState extends State<Preset2Page> {//will not have the bottom bar, only back button
  double db_valueOV = 0.0;
  double db_valueSB_BS = 0.0;
  double db_valueSB_MRS = 0.0;
  double db_valueSB_TS = 0.0;

  double overall_volume = 0;
  double base_sounds = 0;
  double mid_range_sounds = 0;
  double treble_sounds = 0;

  bool reduce_background_noise = false;
  bool reduce_wind_noise = false;
  bool soften_sudden_noise = false;
  //its either true = on, or false = off

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Preset 2 [OLD]',
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          //this will be for the header
          children: [
            //'Overall Volume' container
            Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  //'Overall Volume' header
                  const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.volume_up,
                          color: Colors.black,
                          size: 30,
                        ),
                        Text(
                          ' Overall Volume',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                  ),
                  //'Softer' -> 'Louder' bar
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Softer'),
                      Text('Louder'),
                    ],
                  ),
                  //constant sliding bar
                  Slider(
                    value: db_valueOV,
                    onChanged: (new_value) {
                      setState(() {
                        db_valueOV = new_value;
                        overall_volume = db_valueOV;
                      });
                    },
                    min: -90.0, // Minimum slider value
                    max: 90.0, // Maximum slider value
                    divisions: 18, // Optional, creates steps
                    label: '${db_valueOV.toStringAsFixed(1)} dB',
                  ),
                  //dB level text
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${overall_volume.toStringAsFixed(1)} dB',
                    ),
                  ),
                ],
              ),
            ),
            //'Sound Balance' container
            Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  //'Sound Balance' header
                  const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.earbuds_rounded,
                          color: Colors.black,
                          size: 30,
                        ),
                        Text(
                          ' Sound Balance',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                  ),

                  //'Bass Sounds' slider
                  Container(
                    child: Column(
                      children: [
                        //'Bass Sounds' -> 'Louder' bar
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bass Sounds'),
                            Text('Louder'),
                          ],
                        ),
                        //constant sliding bar
                        Slider(
                          value: db_valueSB_BS,
                          onChanged: (new_value) {
                            setState(() {
                              db_valueSB_BS = new_value;
                              base_sounds = db_valueSB_BS;
                            });
                          },
                          min: -90.0, // Minimum slider value
                          max: 90.0, // Maximum slider value
                          divisions: 18, // Optional, creates steps
                          label: '${db_valueSB_BS.toStringAsFixed(1)} dB',
                        ),
                        //enhancing deep sounds text
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enhances deep sounds like background noise and speech fundamentals\n',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //'Mid-Range Sounds' slider
                  Container(
                    child: Column(
                      children: [
                        //'Mid-Range Sounds' -> 'Louder' bar
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mid-Range Sounds'),
                            Text('Louder'),
                          ],
                        ),
                        //constant sliding bar
                        Slider(
                          value: db_valueSB_MRS,
                          onChanged: (new_value) {
                            setState(() {
                              db_valueSB_MRS = new_value;
                              mid_range_sounds = db_valueSB_MRS;
                            });
                          },
                          min: -90.0, // Minimum slider value
                          max: 90.0, // Maximum slider value
                          divisions: 18, // Optional, creates steps
                          label: '${db_valueSB_MRS.toStringAsFixed(1)} dB',
                        ),
                        //enhancing main speech text
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enhances main speech sounds and voices\n',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //'Treble Sounds' slider
                  Container(
                    child: Column(
                      children: [
                        //'Softer' -> 'Louder' bar
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Treble Sounds'),
                            Text('Louder'),
                          ],
                        ),
                        //constant sliding bar
                        Slider(
                          value: db_valueSB_TS,
                          onChanged: (new_value) {
                            setState(() {
                              db_valueSB_TS = new_value;
                              overall_volume = db_valueSB_TS;
                            });
                          },
                          min: -90.0, // Minimum slider value
                          max: 90.0, // Maximum slider value
                          divisions: 18, // Optional, creates steps
                          label: '${db_valueSB_TS.toStringAsFixed(1)} dB',
                        ),
                        //dB level text
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Enhances clarity and crisp sounds like consonants\n',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //'Sound Enhancement' container
            Container(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  //'Sound Enhancement' header
                  const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_sharp,
                          color: Colors.black,
                          size: 30,
                        ),
                        Text(
                          ' Sound Enhancement',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]
                  ),
                  //reduce background noise section
                  Row(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reduce Background Noise',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Minimize constant background sounds',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Switch(
                            value: reduce_background_noise,
                            onChanged: (value) {
                              setState(() {
                                reduce_background_noise = value; // Update the toggle state
                              });
                            },
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                            inactiveTrackColor: Colors.grey,
                          );
                        },
                      )
                    ],
                  ),
                  //reduce wind noise section
                  Row(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reduce Wind Noise',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Helps in outdoor environments',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Switch(
                            value: reduce_wind_noise,
                            onChanged: (value) {
                              setState(() {
                                reduce_wind_noise = value; // Update the toggle state
                              });
                            },
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                            inactiveTrackColor: Colors.grey,
                          );
                        },
                      )
                    ],
                  ),
                  //soften sudden sounds section
                  Row(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Soften Sudden Sounds',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Reduces unexpected loud noises',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Switch(
                            value: soften_sudden_noise,
                            onChanged: (value) {
                              setState(() {
                                soften_sudden_noise = value; // Update the toggle state
                              });
                            },
                            activeColor: Colors.white,
                            inactiveThumbColor: Colors.white,
                            activeTrackColor: const Color.fromRGBO(133, 86, 169, 1.00),
                            inactiveTrackColor: Colors.grey,
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            //'Save' and 'Delete' buttons container
            Container(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //save
                  ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('\'Preset 1\' Successfully Saved!'),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00), // Button background color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          Text(
                            " Save",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      )
                  ),
                  //delete
                  ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('\'Preset 1\' Successfully Deleted!'),
                            duration: Duration(seconds: 4),
                          ),
                        );
                        Navigator.pop(context); // Custom behavior for back button
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00), // Button background color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever),
                          Text(
                            " Delete",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      )

                  ),
                ],
              ),
            )
          ],
        ),
      ),
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
}//we leave this empty, nothing goes here!
