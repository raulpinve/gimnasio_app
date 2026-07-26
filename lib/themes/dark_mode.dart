import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkMode = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  colorScheme: ColorScheme.dark(
    primary: const Color.fromARGB(255, 105, 105, 105),
    secondary: const Color.fromARGB(255, 15, 15, 15),
    tertiary: const Color.fromARGB(255, 35, 35, 35),
    inversePrimary: Colors.grey.shade300,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 25, 25, 25),
);
