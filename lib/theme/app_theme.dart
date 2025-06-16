import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Contra Kit Inspired Color Palette
  static const Color primaryWhite = Color(0xFFFAFAFA);
  static const Color softGray = Color(0xFFF5F5F5);
  static const Color lightGray = Color(0xFFE8E8E8);
  static const Color mediumGray = Color(0xFFB8B8B8);
  static const Color darkGray = Color(0xFF6B6B6B);
  static const Color charcoal = Color(0xFF2A2A2A);

  // Accent Colors from Contra Kit
  static const Color softBlue = Color(0xFF6B9EFF);
  static const Color lightBlue = Color(0xFFB8D4FF);
  static const Color accentPink = Color(0xFFFF8FB8);
  static const Color lightPink = Color(0xFFFFB8D4);
  static const Color warmOrange = Color(0xFFFFB366);
  static const Color softGreen = Color(0xFF66D9A6);
  static const Color lightGreen = Color(0xFFB8F2D9);

  // Bitcoin accent
  static const Color bitcoinGold = Color(0xFFF7931A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: softBlue,
        secondary: accentPink,
        tertiary: bitcoinGold,
        surface: primaryWhite,
        surfaceContainerHighest: softGray,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: charcoal,
        outline: lightGray,
        outlineVariant: mediumGray,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: primaryWhite,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryWhite,
        foregroundColor: charcoal,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        toolbarHeight: 60,
        iconTheme: const IconThemeData(color: charcoal, size: 24),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: charcoal,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: charcoal,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: charcoal,
        ),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: darkGray),
        bodySmall: GoogleFonts.inter(fontSize: 12, color: mediumGray),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: softBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: softBlue.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: charcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoal,
          side: const BorderSide(color: lightGray, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: primaryWhite,
        elevation: 2,
        shadowColor: charcoal.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: softBlue, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          color: darkGray,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: GoogleFonts.inter(color: mediumGray),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: bitcoinGold,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primaryWhite,
        selectedItemColor: softBlue,
        unselectedItemColor: mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: charcoal,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: lightGray,
        thickness: 1,
        space: 16,
      ),
    );
  }
}
