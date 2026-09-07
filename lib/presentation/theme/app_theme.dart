import 'package:flutter/material.dart';

class AppTheme {
  static const Color remoteBody = Color(0xFF2A2D35);
  static const Color remoteBodyLight = Color(0xFF3A3F4A);
  static const Color displayBg = Color(0xFF0D1B1E);
  static const Color displayGlow = Color(0xFF00E5A0);
  static const Color accent = Color(0xFF4FC3F7);
  static const Color powerRed = Color(0xFFE53935);
  static const Color buttonFace = Color(0xFF3E4450);
  static const Color buttonEdge = Color(0xFF1A1C22);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121418),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1D24),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
