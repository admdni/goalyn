import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Editorial palette — refined, magazine-grade. Cream-and-ink in light mode,
/// warm-ink in dark mode, with a single accent color used sparingly.
///
/// Static const values keep our existing widgets compiling. Theme-aware
/// access is provided via the `context.palette` extension in
/// `core/theme/app_palette.dart`.
class AppColors {
  AppColors._();

  // No-op kept for forward compatibility with the runtime palette idea.
  static void applyMode(Brightness b) {}

  // Accent — refined emerald. Used sparingly.
  static const Color primary = Color(0xFF1F7A4D);
  static const Color primaryLight = Color(0xFF4CAF6A);
  static const Color primaryDark = Color(0xFF155A38);

  // Background — warm ink with subtle paper feel.
  static const Color background = Color(0xFF0E0E0C);
  static const Color backgroundSecondary = Color(0xFF131310);
  static const Color backgroundElevated = Color(0xFF1A1A17);
  static const Color backgroundCard = Color(0xFF161613);

  // Surface
  static const Color surface = Color(0xFF18181A);
  static const Color surfaceLight = Color(0xFF1F1F1B);

  // Text — warm whites for editorial mood.
  static const Color textPrimary = Color(0xFFF4EFE6);
  static const Color textSecondary = Color(0xFFB7B0A0);
  static const Color textTertiary = Color(0xFF6E6A60);
  static const Color textInverse = Color(0xFF0E0E0C);

  // Status
  static const Color live = Color(0xFFE63946);
  static const Color liveSoft = Color(0xFFEF6C71);
  static const Color success = Color(0xFF1F7A4D);
  static const Color warning = Color(0xFFCC8B00);
  static const Color error = Color(0xFFE63946);
  static const Color info = Color(0xFF3D6FB8);

  // Match
  static const Color win = success;
  static const Color draw = warning;
  static const Color loss = error;

  // Cards
  static const Color card = Color(0xFF161613);
  static const Color cardBorder = Color(0xFF26241F);
  static const Color cardHighlight = Color(0xFF1E1C18);

  // Divider
  static const Color divider = Color(0xFF22201C);

  // League brand colors
  static const Color premierLeague = Color(0xFF3D195B);
  static const Color laLiga = Color(0xFFEE8707);
  static const Color bundesliga = Color(0xFFCD1C2A);
  static const Color serieA = Color(0xFF024494);
  static const Color ligue1 = Color(0xFFDA291C);
  static const Color championsLeague = Color(0xFF1A3D8F);
  static const Color superLig = Color(0xFFFFEB00);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1F7A4D), Color(0xFF155A38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient liveGradient = LinearGradient(
    colors: [Color(0xFFE63946), Color(0xFFEF6C71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF161613), Color(0xFF131310)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient overlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC0E0E0C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'SF Pro Display';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.15,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
  );

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Score
  static const TextStyle scoreLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.0,
  );

  static const TextStyle scoreMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.05,
  );

  static const TextStyle scoreSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.1,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const bg = Color(0xFFF2EDE2);
    const surface = Color(0xFFFAF6EC);
    const card = Color(0xFFFAF6EC);
    const cardBorder = Color(0xFFD9D2C2);
    const textPrimary = Color(0xFF0E0E0C);
    const textSecondary = Color(0xFF4A463C);
    const textTertiary = Color(0xFF8E8B7E);
    const primary = Color(0xFF1F7A4D);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: Color(0xFF1B59C5),
        surface: surface,
        error: Color(0xFFD32F2F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle:
            AppTypography.headlineMedium.copyWith(color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: cardBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textTertiary,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: cardBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: cardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: primary, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTypography.labelMedium,
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.3);
          }
          return cardBorder;
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.info,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textInverse,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelMedium,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTypography.labelSmall.copyWith(color: AppColors.textInverse),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary.withOpacity(0.3);
          return AppColors.surface;
        }),
      ),
    );
  }
}
