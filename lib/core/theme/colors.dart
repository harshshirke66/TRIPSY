import 'package:flutter/material.dart';

class TripsyColors {
  // Brand Backgrounds - Obsidian & Basalt
  static const Color deepSpace = Color(0xFF020204);
  static const Color spaceBackground = Color(0xFF07070B);
  static const Color cardBackground = Color(0xFF0F0F16);
  
  // Brand Accents - Neon Red-Pink, Electric Violet, Cyber Teal, Sunrise Gold
  static const Color sunsetOrange = Color(0xFFFE2C55); // Sunset Rose (Neon Pink-Red)
  static const Color peachBurn = Color(0xFFFF9F0A);    // Gold Sunrise (Neon Gold-Amber)
  static const Color oceanTeal = Color(0xFF00E5FF);    // Ocean Wave (Cyber Teal)
  static const Color skyBlue = Color(0xFF9D4EDD);      // Electric Lavender (Royal Purple)
  
  // Neutral Text - True Whites and Lavender Grays
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EAEC8);
  static const Color textMuted = Color(0xFF5A6982);
  
  // State Colors
  static const Color activeGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF1744);
  static const Color warningAmber = Color(0xFFFFB300);
  
  // Glassmorphic Details
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassHighlight = Color(0x0AFFFFFF);

  // Premium Custom Gradients
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [sunsetOrange, peachBurn],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [skyBlue, oceanTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSpaceGradient = LinearGradient(
    colors: [deepSpace, spaceBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
