import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkMode = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: Colors.grey.shade100,
    displayColor: Colors.grey.shade100,
  ),

  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF60A5FA),
    secondary: const Color(0xFF172554),
    surface: const Color(0xFF1E293B),
    inversePrimary: const Color(0xFFBFDBFE),
  ),

  scaffoldBackgroundColor: const Color(0xFF0F172A),
);
