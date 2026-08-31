import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: const Color(0xFF0F172A),
    displayColor: const Color(0xFF0F172A),
  ),

  colorScheme: ColorScheme.light(
    primary: const Color(0xFF2563EB),
    onPrimary: Colors.white,
    secondary: const Color(0xFFDBEAFE),
    onSecondary: const Color(0xFF1E3A8A),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF0F172A),
    surfaceContainerHighest: const Color(
      0xFFE2E8F0,
    ),
    outline: const Color(0xFFCBD5E1), // bordes/divisores visibles
    inversePrimary: const Color(0xFF1E3A8A),
    tertiary: const Color(
      0xFFF97316,
    ),
  ),

  scaffoldBackgroundColor: const Color(
    0xFFEEF2F6,
  ), // más separado del blanco puro

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(
        color: Color(0xFFE2E8F0),
      ),
    ),
  ),

  dividerColor: const Color(0xFFE2E8F0),
);
