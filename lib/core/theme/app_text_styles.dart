import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // Body
  static const TextStyle body1 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle body3 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Labels
  static const TextStyle label1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle label2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // Score
  static const TextStyle scoreLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.0,
  );

  static const TextStyle scoreMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.1,
  );

  static const TextStyle scoreSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.1,
  );

  // Tab
  static const TextStyle tab = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Dark Theme
  static TextStyle headline1Dark = headline1.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle headline2Dark = headline2.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle headline3Dark = headline3.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle headline4Dark = headline4.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle body1Dark = body1.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle body2Dark = body2.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle body3Dark = body3.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle label1Dark = label1.copyWith(color: AppColors.textTertiaryDark);
  static TextStyle label2Dark = label2.copyWith(color: AppColors.textTertiaryDark);
  static TextStyle scoreLargeDark = scoreLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle scoreMediumDark = scoreMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle scoreSmallDark = scoreSmall.copyWith(color: AppColors.textPrimaryDark);

  // Light Theme
  static TextStyle headline1Light = headline1.copyWith(color: AppColors.textPrimaryLight);
  static TextStyle headline2Light = headline2.copyWith(color: AppColors.textPrimaryLight);
  static TextStyle headline3Light = headline3.copyWith(color: AppColors.textPrimaryLight);
  static TextStyle headline4Light = headline4.copyWith(color: AppColors.textPrimaryLight);
  static TextStyle body1Light = body1.copyWith(color: AppColors.textPrimaryLight);
  static TextStyle body2Light = body2.copyWith(color: AppColors.textSecondaryLight);
  static TextStyle body3Light = body3.copyWith(color: AppColors.textSecondaryLight);
  static TextStyle label1Light = label1.copyWith(color: AppColors.textTertiaryLight);
  static TextStyle label2Light = label2.copyWith(color: AppColors.textTertiaryLight);
  static TextStyle scoreLargeLight = scoreLarge.copyWith(color: AppColors.textPrimaryLight);
  static TextStyle scoreMediumLight = scoreMedium.copyWith(color: AppColors.textPrimaryLight);
  static TextStyle scoreSmallLight = scoreSmall.copyWith(color: AppColors.textPrimaryLight);
}