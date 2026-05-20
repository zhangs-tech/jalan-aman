import 'package:flutter/material.dart';

/// Jalan Aman — Design Token Colors
/// Source: design spec v1
abstract final class AppColors {
  // ─── Brand ────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A6B3C);
  static const Color primaryLight = Color(0xFF2E8F54);
  static const Color primaryDark = Color(0xFF104828);

  static const Color accent = Color(0xFFF5A623);
  static const Color accentLight = Color(0xFFFBCC78);
  static const Color accentDark = Color(0xFFB87718);

  // ─── Semantic ─────────────────────────────────────────────
  static const Color danger = Color(0xFFD0021B);
  static const Color dangerBackground = Color(0xFFFEE2E2);

  static const Color success = Color(0xFF059669);
  static const Color successBackground = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFD97706);
  static const Color warningBackground = Color(0xFFFEF3C7);

  static const Color info = Color(0xFF1D4ED8);
  static const Color infoBackground = Color(0xFFDBEAFE);

  // ─── Neutral ──────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8EEE9);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFFB0B8B4);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE2E8E4);
  static const Color borderStrong = Color(0xFFCDD5D0);

  static const Color divider = Color(0xFFF0F3F1);

  // ─── Status Badge Colors ───────────────────────────────────
  /// Use [AppColors.statusColor] and [AppColors.statusBackground]
  /// to resolve colors by status string.
  static const Color statusPendingFg = warning;
  static const Color statusPendingBg = warningBackground;

  static const Color statusInProgressFg = info;
  static const Color statusInProgressBg = infoBackground;

  static const Color statusResolvedFg = success;
  static const Color statusResolvedBg = successBackground;

  static const Color statusRejectedFg = danger;
  static const Color statusRejectedBg = dangerBackground;

  // ─── Map Pin Colors ────────────────────────────────────────
  static const Color pinPending = warning;
  static const Color pinInProgress = info;
  static const Color pinResolved = success;
  static const Color pinRejected = danger;

  // ─── Shadow ───────────────────────────────────────────────
  static const Color shadowColor = Color(0x0F000000); // rgba(0,0,0,0.06)

  // ─── Helpers ──────────────────────────────────────────────
  static Color statusForeground(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPendingFg;
      case 'in progress':
        return statusInProgressFg;
      case 'resolved':
        return statusResolvedFg;
      case 'rejected':
        return statusRejectedFg;
      default:
        return textSecondary;
    }
  }

  static Color statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPendingBg;
      case 'in progress':
        return statusInProgressBg;
      case 'resolved':
        return statusResolvedBg;
      case 'rejected':
        return statusRejectedBg;
      default:
        return surfaceVariant;
    }
  }

  static Color pinColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pinPending;
      case 'in progress':
        return pinInProgress;
      case 'resolved':
        return pinResolved;
      case 'rejected':
        return pinRejected;
      default:
        return textSecondary;
    }
  }
}