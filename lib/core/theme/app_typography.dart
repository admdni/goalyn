import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium editorial typography. Pairs an italic-rich display serif with a
/// modern sans for body, and a mono with tabular figures for scores/data.
///
/// Display: Instrument Serif (characterful italic-leaning serif).
/// Sans:    Instrument Sans (clean, slightly condensed).
/// Mono:    JetBrains Mono (tabular figures for scores).
class AppType {
  AppType._();

  static const _displayFamily = 'InstrumentSerif';
  static const _sansFamily = 'InstrumentSans';
  static const _monoFamily = 'JetBrainsMono';

  static TextStyle display({
    double size = 48,
    Color? color,
    FontStyle style = FontStyle.normal,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = -0.5,
    double height = 0.95,
  }) =>
      GoogleFonts.getFont(
        'Instrument Serif',
        fontSize: size,
        color: color,
        fontStyle: style,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle serif({
    double size = 18,
    Color? color,
    FontStyle style = FontStyle.normal,
    FontWeight weight = FontWeight.w400,
    double height = 1.4,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.getFont(
        'Instrument Serif',
        fontSize: size,
        color: color,
        fontStyle: style,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle sans({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.35,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.getFont(
        'Instrument Sans',
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Tabular figures via JetBrains Mono — perfect for scores.
  static TextStyle mono({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w500,
    double height = 1.0,
    double letterSpacing = -0.5,
  }) =>
      GoogleFonts.getFont(
        'JetBrains Mono',
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Tiny caps with strong tracking — used for kickers and section labels.
  static TextStyle eyebrow({
    double size = 10,
    Color? color,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 1.6,
  }) =>
      GoogleFonts.getFont(
        'Instrument Sans',
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: 1.2,
      );

  /// String → uppercase eyebrow text helper.
  static String spaced(String s) => s.toUpperCase();

  // Legacy family constants kept for compatibility.
  static String get display_family => _displayFamily;
  static String get sans_family => _sansFamily;
  static String get mono_family => _monoFamily;
}
