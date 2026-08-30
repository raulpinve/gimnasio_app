import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,

  scaffoldBackgroundColor: const Color(0xFF101010),

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF78909C),
    secondary: Color(0xFF262626),
    surface: Color(0xFF1A1A1A),
    inversePrimary: Color(0xFFB0BEC5),
  ),

  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: const Color(0xFFE5E5E5),
    displayColor: const Color(0xFFFFFFFF),
  ),
);
