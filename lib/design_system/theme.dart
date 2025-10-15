import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class SafePlayTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: SafePlayColors.brandTeal500,
        secondary: SafePlayColors.brandOrange500,
        error: SafePlayColors.error,
        background: SafePlayColors.neutral50,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: SafePlayColors.neutral900,
        onSurface: SafePlayColors.neutral900,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: SafePlayColors.neutral900,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: SafePlayColors.neutral900,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: SafePlayColors.neutral900,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: SafePlayColors.neutral900,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: SafePlayColors.neutral900,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: SafePlayColors.neutral900,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          color: SafePlayColors.neutral700,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          color: SafePlayColors.neutral700,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          color: SafePlayColors.neutral500,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: SafePlayColors.neutral700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SafePlayColors.brandTeal500,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SafePlayColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SafePlayColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: SafePlayColors.brandTeal500,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SafePlayColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
