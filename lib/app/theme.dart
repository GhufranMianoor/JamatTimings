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
  static const Color primaryGreen = Color(0xFFC6A24A); // antique gold
  static const Color accentGold = Color(0xFFD8C59A); // soft khaki
  static const Color creamBackground = Color(0xFFF6EED9); // parchment cream
  static const Color creamSurface = Color(0xFFFCF7EB);

  static const Color darkPrimaryGreen = Color(0xFFE2C16D);
  static const Color darkAccentGold = Color(0xFFC5B07A);
  static const Color darkBackground = Color(0xFF17150F);
  static const Color darkSurface = Color(0xFF231F17);
  static const Color lightSurfaceVariant = Color(0xFFE7D9BB);
  static const Color darkSurfaceVariant = Color(0xFF3A3224);
  static const Color lightInk = Color(0xFF2B1E10);
  static const Color darkInk = Color(0xFFF5E9CF);
  static const Color warmBorder = Color(0xFFCCB47A);
  static const Color darkBorder = Color(0xFF7D6A43);

  // Prayer-specific colors
  static final Map<String, Color> prayerColors = {
    'fajr': const Color(0xFF3F51B5),    // Indigo
    'dhuhr': const Color(0xFFFF8F00),   // Amber
    'asr': const Color(0xFFE65100),     // Deep Orange
    'maghrib': const Color(0xFFB71C1C), // Deep Red
    'isha': const Color(0xFF4A148C),    // Deep Purple
    'jumuah': const Color(0xFF1B5E20),  // Deep Green
    'taraweeh': const Color(0xFF00695C),// Teal
    'eid': const Color(0xFFFFD600),     // Bright Gold
  };

  static Color getPrayerColor(String prayer) {
    return prayerColors[prayer.toLowerCase()] ?? primaryGreen;
  }

  static TextTheme _amiriTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textColor = brightness == Brightness.dark ? darkInk : lightInk;

    return GoogleFonts.amiriTextTheme(base).copyWith(
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
      primary: primaryGreen,
      onPrimary: lightInk,
      secondary: accentGold,
      onSecondary: lightInk,
      tertiary: Color(0xFF6F7D4A),
      onTertiary: Colors.white,
      surface: creamSurface,
      onSurface: lightInk,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      outline: warmBorder,
    );
  }

  static ColorScheme _darkColorScheme() {
    return const ColorScheme.dark(
      primary: darkPrimaryGreen,
      onPrimary: darkBackground,
      secondary: darkAccentGold,
      onSecondary: darkBackground,
      tertiary: Color(0xFF8F9E67),
      onTertiary: darkBackground,
      surface: darkSurface,
      onSurface: darkInk,
      error: Color(0xFFF2B8B5),
      onError: darkBackground,
      outline: darkBorder,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme(),
      scaffoldBackgroundColor: creamBackground,
      canvasColor: creamBackground,
      textTheme: _amiriTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: creamSurface,
        foregroundColor: lightInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: creamSurface,
        elevation: 1,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightSurfaceVariant, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: lightInk,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: creamSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: warmBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightSurfaceVariant),
        ),
        labelStyle: const TextStyle(color: lightInk),
        hintStyle: const TextStyle(color: Color(0xFF6E5E43)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1E5C7),
        selectedColor: accentGold,
        labelStyle: const TextStyle(color: lightInk),
        side: const BorderSide(color: lightSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: const DividerThemeData(
        color: lightSurfaceVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: primaryGreen),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: lightInk,
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: creamSurface,
        indicatorColor: const Color(0xFFF1E5C7),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? lightInk : const Color(0xFF6E5E43),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primaryGreen : const Color(0xFF8D7B5A));
        }),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightInk,
          side: const BorderSide(color: warmBorder),
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
      scaffoldBackgroundColor: darkBackground,
      canvasColor: darkBackground,
      textTheme: _amiriTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkSurfaceVariant, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryGreen,
          foregroundColor: darkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkPrimaryGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkSurfaceVariant),
        ),
        labelStyle: const TextStyle(color: darkInk),
        hintStyle: const TextStyle(color: Color(0xFFBFAE8D)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceVariant,
        selectedColor: darkAccentGold,
        labelStyle: const TextStyle(color: darkInk),
        side: const BorderSide(color: darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: const DividerThemeData(
        color: darkSurfaceVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: darkPrimaryGreen),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryGreen,
        foregroundColor: darkBackground,
        elevation: 2,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: darkSurfaceVariant,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? darkInk : const Color(0xFFBFAE8D),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? darkPrimaryGreen : const Color(0xFF9B8A67));
        }),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkInk,
          side: const BorderSide(color: darkBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }
}
