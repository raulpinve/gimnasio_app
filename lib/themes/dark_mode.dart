import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkMode = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: const Color(0xFFF1F5F9),
    displayColor: const Color(0xFFF1F5F9),
  ),

  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF60A5FA),
    onPrimary: const Color(0xFF0F172A),
    secondary: const Color(0xFF1E293B),
    onSecondary: const Color(0xFFBFDBFE),
    surface: const Color(0xFF1E1E1E),
    onSurface: const Color(0xFFF1F5F9),
    surfaceContainerHighest: const Color(0xFF2A2A2A),
    outline: const Color(0xFF3A3A3A),
    inversePrimary: const Color(0xFF1E3A8A),
    tertiary: const Color(0xFFFB923C),
  ),

  scaffoldBackgroundColor: const Color(
    0xFF121212,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFF2A2A2A)),
    ),
  ),

  dividerColor: const Color(0xFF2A2A2A),
);
