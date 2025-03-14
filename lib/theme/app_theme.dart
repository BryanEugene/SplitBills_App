import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    primaryColor: Color(0xFF1E88E5),
    scaffoldBackgroundColor: Colors.grey[50],
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF1E88E5),
      secondary: Color(0xFF00ACC1),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1E88E5),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
