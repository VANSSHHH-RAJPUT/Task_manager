import 'package:flutter/material.dart';

class AppTheme {
  // Premium Gold & Black Palette
  static const Color gold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB68A1E);
  static const Color black = Color(0xFF0B0B0B);
  static const Color charcoal = Color(0xFF161616);
  static const Color softBlack = Color(0xFF1E1E1E);
  static const Color champagne = Color(0xFFF7F1E3);
  static const Color warmWhite = Color(0xFFFFF8E7);
  static const Color errorRed = Color(0xFFCF6679);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: gold,
      onPrimary: black,
      secondary: darkGold,
      onSecondary: warmWhite,
      surface: warmWhite,
      onSurface: black,
      error: errorRed,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.transparent, // For gradient backgrounds
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: black),
      titleTextStyle: TextStyle(color: black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    fontFamily: 'Roboto', // Or user's custom font
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      onPrimary: black,
      secondary: darkGold,
      onSecondary: black,
      surface: softBlack,
      onSurface: warmWhite,
      error: errorRed,
      onError: black,
    ),
    scaffoldBackgroundColor: Colors.transparent, // For gradient backgrounds
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: gold),
      titleTextStyle: TextStyle(color: gold, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    fontFamily: 'Roboto', // Or user's custom font
  );
}
