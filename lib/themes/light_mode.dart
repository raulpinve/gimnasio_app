import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: Colors.grey.shade900,
    displayColor: Colors.grey.shade900,
  ),

  colorScheme: ColorScheme.light(
    primary: const Color(0xFF2563EB),
    secondary: const Color(0xFFEFF6FF),
    surface: const Color(0xFFFFFFFF),
    inversePrimary: const Color(0xFF1E3A8A),
  ),

  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
);
