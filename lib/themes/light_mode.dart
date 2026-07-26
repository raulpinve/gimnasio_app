import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightMode = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: Colors.grey.shade900,
    displayColor: Colors.grey.shade900,
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade100,
    tertiary: Colors.white,
    inversePrimary: Colors.grey.shade900,
  ),
  scaffoldBackgroundColor: Colors.grey.shade100,
);
