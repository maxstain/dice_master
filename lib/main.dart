import 'package:dice_master/pages/splash_screen.dart';
import 'package:dice_master/utils/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The current theme of the system
  final ThemeMode systemTheme = ThemeMode.system;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Master',
      theme: systemTheme == ThemeMode.light
          ? AppTheme.lightTheme
          : AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
