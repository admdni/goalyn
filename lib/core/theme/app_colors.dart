import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF00FF87);
  static const Color primaryLight = Color(0xFF66FFAA);
  static const Color primaryDark = Color(0xFF00CC6A);

  // Accent Colors
  static const Color accent = Color(0xFF00FF87);
  static const Color accentSecondary = Color(0xFF00D4FF);

  // Background Colors
  static const Color backgroundDark = Color(0xFF0A0A0F);
  static const Color backgroundDarkSecondary = Color(0xFF12121A);
  static const Color backgroundDarkTertiary = Color(0xFF1A1A24);
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundLightSecondary = Color(0xFFFFFFFF);
  static const Color backgroundLightTertiary = Color(0xFFF0F0F2);

  // Surface Colors
  static const Color surfaceDark = Color(0xFF1E1E28);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Card Colors
  static const Color cardDark = Color(0xFF1A1A24);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B8);
  static const Color textTertiaryDark = Color(0xFF6B6B75);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  static const Color textTertiaryLight = Color(0xFF9B9B9B);

  // Match Status Colors
  static const Color liveRed = Color(0xFFFF3B3B);
  static const Color liveGreen = Color(0xFF00FF87);
  static const Color finishedBlue = Color(0xFF007AFF);
  static const Color scheduledGray = Color(0xFF8E8E93);

  // Card Colors
  static const Color yellowCard = Color(0xFFFFD700);
  static const Color redCard = Color(0xFFFF3B30);

  // Score Colors
  static const Color scoreHighlight = Color(0xFF00FF87);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00FF87), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF1A1A24), Color(0xFF12121A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient liveGradient = LinearGradient(
    colors: [Color(0xFFFF3B3B), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status Bar Colors
  static const Color statusBarDark = Color(0xFF0A0A0F);
  static const Color statusBarLight = Color(0xFFF5F5F7);

  // Divider Colors
  static const Color dividerDark = Color(0xFF2A2A35);
  static const Color dividerLight = Color(0xFFE5E5EA);

  // Success/Warning/Error
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
}
