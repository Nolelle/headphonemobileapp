import 'package:flutter/material.dart';

class SoundTestPage extends StatefulWidget {
  const SoundTestPage({super.key});

  @override
  State<SoundTestPage> createState() => _SoundTestPageState();
}

class _SoundTestPageState extends State<SoundTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(237, 212, 254, 1.00),
      appBar: AppBar(
        title: const Text('Hearing Test'),
        backgroundColor: const Color.fromRGBO(133, 86, 169, 1.00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hearing Test',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'This feature will help you test your hearing and create a personalized audio profile.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Coming Soon Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.hearing,
                        size: 60,
                        color: Color.fromRGBO(133, 86, 169, 1.00),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(133, 86, 169, 1.00),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'The hearing test feature is currently under development. Check back soon!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Feature coming in a future update!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(133, 86, 169, 1.00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Notify Me When Available',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
