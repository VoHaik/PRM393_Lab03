import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant, clean light mode palette matching the Scientia Analytics theme
  static const Color darkBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color darkCardBackground = Color(0xFFFFFFFF); // Pure White
  static const Color primaryNeon = Color(0xFFEA580C); // Vibrant Orange (Orange 600)
  static const Color secondaryNeon = Color(0xFF475569); // Slate 600
  static const Color accentRose = Color(0xFFEF4444); // Red 500
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color borderNeon = Color(0xFFE2E8F0); // Slate 200

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryNeon,
        secondary: secondaryNeon,
        surface: darkCardBackground,
        error: accentRose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderNeon, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryNeon),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBackground,
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: primaryNeon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: borderNeon),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: borderNeon),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryNeon, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Helper for glassmorphic/flat container
  static BoxDecoration glassBox({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? darkCardBackground,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: border ?? Border.all(color: borderNeon),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
