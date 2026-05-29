import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
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
  static const Color pureBlack = Color(0xFF000000);
  static const Color deepEmerald = Color(0xFF064E3B);
  static const Color warmGold = Color(0xFFF59E0B);
  static const Color burnishedGold = Color(0xFFD97706);
  static const Color sageKhaki = Color(0xFFD4AF37);
  static const Color darkCard = Color(0xFF121212);
  static const Color darkCardAlt = Color(0xFF171717);
  static const Color parchmentInk = Color(0xFFF6E9C8);
  static const Color mutedInk = Color(0xFFB9A87D);
  static const Color subtleBorder = Color(0x1A374151);
  static const Color strongBorder = Color(0x40374151);
  static const Color chipBorder = Color(0x264E5D56);
  static const Color lightCanvas = Color(0xFFFAF3E3);
  static const Color lightSurface = Color(0xFFFFF9EF);
  static const Color lightInk = Color(0xFF241A10);

  // Prayer-specific colors
  static final Map<String, Color> prayerColors = {
    'fajr': const Color(0xFF90CAF9),
    'dhuhr': warmGold,
    'asr': burnishedGold,
    'maghrib': const Color(0xFFDC8B5B),
    'isha': const Color(0xFF5EEAD4),
    'jumuah': sageKhaki,
    'taraweeh': deepEmerald,
    'eid': const Color(0xFFFFD54F),
  };

  static Color getPrayerColor(String prayer) {
    return prayerColors[prayer.toLowerCase()] ?? sageKhaki;
  }

  static TextTheme _luxuryTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textColor = brightness == Brightness.dark ? parchmentInk : lightInk;

    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        fontSize: 34,
        color: textColor,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        fontSize: 30,
        color: textColor,
        height: 1.12,
      ),
      displaySmall: GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        fontSize: 26,
        color: textColor,
        height: 1.15,
      ),
      headlineLarge: GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: textColor,
        height: 1.18,
      ),
      headlineMedium: GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: textColor,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: textColor,
        height: 1.25,
      ),
      titleMedium: GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: textColor,
        height: 1.3,
      ),
      bodyLarge: GoogleFonts.amiri(
        fontSize: 16,
        color: textColor,
        height: 1.55,
      ),
      bodyMedium: GoogleFonts.amiri(
        fontSize: 14,
        color: textColor,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.amiri(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: textColor,
        height: 1.2,
      ),
    );
  }

  static ColorScheme _lightColorScheme() {
    return const ColorScheme.light(
      primary: burnishedGold,
      onPrimary: Colors.white,
      secondary: deepEmerald,
      onSecondary: Colors.white,
      tertiary: sageKhaki,
      onTertiary: Colors.black,
      surface: lightSurface,
      onSurface: lightInk,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      outline: strongBorder,
    );
  }

  static ColorScheme _darkColorScheme() {
    return const ColorScheme.dark(
      primary: warmGold,
      onPrimary: pureBlack,
      secondary: deepEmerald,
      onSecondary: parchmentInk,
      tertiary: sageKhaki,
      onTertiary: pureBlack,
      surface: darkCard,
      onSurface: parchmentInk,
      error: Color(0xFFF2B8B5),
      onError: pureBlack,
      outline: subtleBorder,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme(),
      scaffoldBackgroundColor: lightCanvas,
      canvasColor: lightCanvas,
      textTheme: _luxuryTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: strongBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warmGold,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: strongBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: warmGold, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: subtleBorder),
        ),
        labelStyle: const TextStyle(color: lightInk),
        hintStyle: const TextStyle(color: Color(0xFF705B3B)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0E3C8),
        selectedColor: warmGold,
        labelStyle: const TextStyle(color: lightInk),
        side: const BorderSide(color: subtleBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: const DividerThemeData(
        color: subtleBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: burnishedGold),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: warmGold,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: const Color(0x33F59E0B),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? lightInk : const Color(0xFF705B3B),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? burnishedGold : const Color(0xFF8D7B5A));
        }),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightInk,
          side: const BorderSide(color: strongBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme(),
      scaffoldBackgroundColor: pureBlack,
      canvasColor: pureBlack,
      textTheme: _luxuryTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: parchmentInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 12,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: subtleBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warmGold,
          foregroundColor: pureBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: warmGold, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: subtleBorder),
        ),
        labelStyle: const TextStyle(color: parchmentInk),
        hintStyle: const TextStyle(color: mutedInk),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedColor: const Color(0xFF123C2C),
        labelStyle: const TextStyle(color: parchmentInk),
        side: const BorderSide(color: chipBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: const DividerThemeData(
        color: subtleBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: warmGold),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: warmGold,
        foregroundColor: pureBlack,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: const Color(0x33264E3B),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? parchmentInk : mutedInk,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? warmGold : mutedInk);
        }),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: parchmentInk,
          side: const BorderSide(color: subtleBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }
}
