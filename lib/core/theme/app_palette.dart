import 'package:flutter/material.dart';

/// Editorial palette — warm paper-and-ink in light mode, ink-on-charcoal in
/// dark mode. A single emerald accent ties the system together.
class AppPalette {
  // Backgrounds
  final Color background;
  final Color paper; // primary content surface
  final Color paperAlt; // slight tonal shift for layering
  final Color ink; // emphatic text/borders
  final Color line; // hairline rules

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;

  // Accents
  final Color accent; // emerald
  final Color accentSoft;
  final Color live;
  final Color warning;
  final Color info;

  const AppPalette({
    required this.background,
    required this.paper,
    required this.paperAlt,
    required this.ink,
    required this.line,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.accent,
    required this.accentSoft,
    required this.live,
    required this.warning,
    required this.info,
  });

  /// Light mode — warm cream paper, deep ink, emerald accent.
  static const AppPalette light = AppPalette(
    background: Color(0xFFF2EDE2), // warm cream
    paper: Color(0xFFFAF6EC),
    paperAlt: Color(0xFFEAE3D2),
    ink: Color(0xFF0E0E0C),
    line: Color(0xFFD9D2C2),
    textPrimary: Color(0xFF0E0E0C),
    textSecondary: Color(0xFF4A463C),
    textTertiary: Color(0xFF8E8B7E),
    textInverse: Color(0xFFFAF6EC),
    accent: Color(0xFF1F7A4D),
    accentSoft: Color(0xFFD4E5DA),
    live: Color(0xFFC6303D),
    warning: Color(0xFFB8770A),
    info: Color(0xFF1F4FB8),
  );

  /// Dark mode — warm ink, paper-bright text.
  static const AppPalette dark = AppPalette(
    background: Color(0xFF0E0E0C),
    paper: Color(0xFF13130F),
    paperAlt: Color(0xFF1B1B16),
    ink: Color(0xFFF4EFE6),
    line: Color(0xFF26241F),
    textPrimary: Color(0xFFF4EFE6),
    textSecondary: Color(0xFFB7B0A0),
    textTertiary: Color(0xFF6E6A60),
    textInverse: Color(0xFF0E0E0C),
    accent: Color(0xFF5BD89A),
    accentSoft: Color(0xFF1B3328),
    live: Color(0xFFFF6B72),
    warning: Color(0xFFFFB74D),
    info: Color(0xFF7FA3FF),
  );
}

extension PaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).brightness == Brightness.light
          ? AppPalette.light
          : AppPalette.dark;
}
