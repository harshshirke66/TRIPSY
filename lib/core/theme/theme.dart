import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripsy/core/theme/colors.dart';

class TripsyTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: TripsyColors.sunsetOrange,
      scaffoldBackgroundColor: TripsyColors.deepSpace,
      cardColor: TripsyColors.cardBackground,
      colorScheme: const ColorScheme.dark(
        primary: TripsyColors.sunsetOrange,
        secondary: TripsyColors.oceanTeal,
        surface: TripsyColors.cardBackground,
        error: TripsyColors.errorRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: TripsyColors.textPrimary,
          ),
          displayMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: TripsyColors.textPrimary,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: TripsyColors.textPrimary,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: TripsyColors.textPrimary,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: TripsyColors.textSecondary,
          ),
          labelLarge: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: TripsyColors.textMuted,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: TripsyColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TripsyColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: TripsyColors.sunsetOrange,
        unselectedItemColor: TripsyColors.textMuted,
      ),
    );
  }
}
