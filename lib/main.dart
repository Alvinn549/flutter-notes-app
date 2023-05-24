import 'package:flutter/material.dart';
import 'package:notes_app/view/main_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainScreen(),
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
    );
  }
}
