import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: const Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text(
              'Q. How do I clean and maintain my headphones?',
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              'Ans: Regular cleaning is essential. Use a soft, dry cloth to wipe the exterior daily, and follow the specific cleaning instructions provided in the app. We also recommend scheduling professional cleanings every few months.',
              style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            const Text(
              'Q. How can I adjust the settings on my headphones?',
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              'Ans: You can adjust your headphone settings through the app. This includes changing the volume, selecting different listening programs. Just go to the equalizer and change according to your environment.',
              style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            const Text(
              'Q. How can I perform a sound test?',
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              'Ans: The sound test is extremely easy to complete. A sound will be played at different frequencies. And the sound keep getting louder overtime. You have to click the button as soon as you hear the sound. You have to do this for every frequency. You responses will be recorded a preset will be made according to that. You can then use that preset in your headphones.',
               style: TextStyle(fontSize: 16),),
          ],
        ),
      ),
    );
  }
}
