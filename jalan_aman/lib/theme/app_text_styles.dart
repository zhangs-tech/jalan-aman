import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Jalan Aman — Typography
///
/// Headings  → Plus Jakarta Sans (Bold / SemiBold)
/// Body      → DM Sans (Regular / Medium)
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   google_fonts: ^6.2.1
/// ```
/// Then replace FontFamily.heading / body constants with:
///   GoogleFonts.plusJakartaSansTextTheme()
///   GoogleFonts.dmSansTextTheme()
abstract final class AppTextStyles {
  // Font family fallbacks (swap with GoogleFonts in main.dart)
  static const String _heading = 'PlusJakartaSans';
  static const String _body = 'DMSans';

  // ─── Display ──────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _heading,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _heading,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  // ─── Headings ─────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: _heading,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _heading,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _heading,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ─── Body ─────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ─── Labels / UI ──────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _body,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  // ─── Button ───────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  // ─── Caption / Overline ───────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: _body,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _body,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.8,
    color: AppColors.textSecondary,
  );

  // ─── Convenience modifiers ────────────────────────────────
  static TextStyle colored(TextStyle base, Color color) =>
      base.copyWith(color: color);
}