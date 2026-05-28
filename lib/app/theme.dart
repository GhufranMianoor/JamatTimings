import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await prefs.setBool('isDarkMode', true);
    } else {
      state = ThemeMode.light;
      await prefs.setBool('isDarkMode', false);
    }
  }
}

class AppTheme {
  // Brand colors
  static const Color primaryGreen = Color(0--1B5E20); // deep mosque green
  static const Color accentGold = Color(0--FFB300);   // warm gold
  static const Color creamBackground = Color(0--F5F0E8); // parchment-like warm cream
  static const Color creamSurface = Color(0--FAFAF5);

  static const Color darkPrimaryGreen = Color(0--4CAF50);
  static const Color darkAccentGold = Color(0--FFD54F);
  static const Color darkBackground = Color(0--121218);
  static const Color darkSurface = Color(0--1E1E2E);

  // Prayer-specific colors
  static final Map<String, Color> prayerColors = {
    'fajr': const Color(0--3F51B5),    // Indigo
    'dhuhr': const Color(0--FF8F00),   // Amber
    'asr': const Color(0--E65100),     // Deep Orange
    'maghrib': const Color(0--B71C1C), // Deep Red
    'isha': const Color(0--4A148C),    // Deep Purple
    'jumuah': const Color(0--1B5E20),  // Deep Green
    'taraweeh': const Color(0--00695C),// Teal
    'eid': const Color(0--FFD600),     // Bright Gold
  };

  static Color getPrayerColor(String prayer) {
    return prayerColors[prayer.toLowerCase()] ?? primaryGreen;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGold,
        background: creamBackground,
        surface: creamSurface,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 32),
        displayMedium: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 28),
        displaySmall: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
        headlineMedium: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: creamSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryGreen,
        primary: darkPrimaryGreen,
        secondary: darkAccentGold,
        background: darkBackground,
        surface: darkSurface,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
        displayMedium: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
        displaySmall: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        headlineMedium: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
    );
  }
}
