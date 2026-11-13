import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ChristysFitApp());
}

class AppColors {
  static const cream = Color(0xFFFDFBF7);
  static const ink = Color(0xFF222222);
  static const lavender = Color(0xFFE2DEEC);
  static const accent = Color(0xFFA9A5C4);
  static const muted = Color(0xFF8A8A8A);
  static const chip = Color(0xFFF0EDE6);
  static const chipSelected = Color(0xFFD8E4DA);
}

class ChristysFitApp extends StatelessWidget {
  const ChristysFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Christy's Fit",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
      ),
      home: const HomeScreen(),
    );
  }
}
