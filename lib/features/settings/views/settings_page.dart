import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Hamburger',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(133, 86, 169, 1.00),
        ),
      ),
    );
  }
}
