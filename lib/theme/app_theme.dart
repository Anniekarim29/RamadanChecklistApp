import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Core Palette ─────────────────────────────────────────────────────────
  static const Color background    = Color(0xFF0B1220);   // deep navy
  static const Color surface       = Color(0xFF151F2E);   // card bg
  static const Color surfaceLight  = Color(0xFF1E2D40);   // elevated card

  // Emerald green (bright, vivid — much more visible)
  static const Color emerald       = Color(0xFF10B981);   // vibrant green
  static const Color emeraldLight  = Color(0xFF34D399);   // lighter green
  static const Color primary       = emerald;
  static const Color primaryLight  = emeraldLight;

  // Gold
  static const Color gold          = Color(0xFFD4AF37);
  static const Color goldLight     = Color(0xFFEDD97A);

  // Text
  static const Color textPrimary   = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFF8FA3C0);
  static const Color textMuted     = Color(0xFF4A5E78);

  // Status
  static const Color success       = Color(0xFF10B981);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color error         = Color(0xFFEF4444);
  static const Color cardBorder    = Color(0xFF1E2D40);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: emerald,
        secondary: gold,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: background,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(color: textPrimary, fontWeight: FontWeight.w900),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
          headlineMedium:TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          titleLarge:    TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          titleMedium:   TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleSmall:    TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
          bodyLarge:     TextStyle(color: textPrimary,   fontWeight: FontWeight.w500),
          bodyMedium:    TextStyle(color: textSecondary, fontWeight: FontWeight.w400),
          bodySmall:     TextStyle(color: textMuted),
          labelLarge:    TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: gold),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: emerald,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emerald,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return emerald;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: textMuted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
