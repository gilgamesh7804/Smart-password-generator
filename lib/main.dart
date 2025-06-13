import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PasswordKeeperApp());
}

class PasswordKeeperApp extends StatelessWidget {
  const PasswordKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Password Keeper',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
