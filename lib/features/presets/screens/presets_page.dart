import 'package:flutter/material.dart';
import 'preset1_page.dart';
import 'preset2_page.dart';

class PresetsPage extends StatefulWidget {
  final Map<String, dynamic> presetData;

  const PresetsPage({super.key, required this.presetData});

  @override
  _PresetsPageState createState() => _PresetsPageState();
}

class _PresetsPageState extends State<PresetsPage> {
  int selectedButton = 0;

  final Color selectedButtonColor = const Color.fromRGBO(93, 59, 129, 1.00);
  final Color unselectedButtonColor = const Color.fromRGBO(133, 86, 169, 1.00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Text(
              "John's Headphones",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text('Battery: 73%',
                style: TextStyle(fontSize: 20, color: Colors.black54)),
            const Text(
              'Connection Status: Connected',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 24),

            // Preset 1 Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedButton = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("'Preset 1' Successfully Sent To Device!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedButton == 0
                    ? selectedButtonColor
                    : unselectedButtonColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Preset 1',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Preset1Page(presetData: widget.presetData),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Preset 2 Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedButton = 1;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("'Preset 2' Successfully Sent To Device!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedButton == 1
                    ? selectedButtonColor
                    : unselectedButtonColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Preset 2',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Preset2Page(presetData: widget.presetData),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
