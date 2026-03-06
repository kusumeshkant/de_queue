import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF1A1A2E),
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
        ),
      );

  static ThemeData get green => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C853),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      );
}
