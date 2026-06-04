import 'package:flutter/material.dart';
import 'app_colors.dart';

// spacing
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // horizontal padding
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: base);

  static const EdgeInsets cardPadding = EdgeInsets.all(base);

  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(horizontal: base, vertical: md);
}

// border radius 
abstract final class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;   // inputs, small chips
  static const double md = 12.0;  // cards
  static const double lg = 16.0;  // bottom sheet top corners
  static const double xl = 20.0;
  static const double pill = 100.0; // status badges, filter pills

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(md));

  static const BorderRadius inputRadius =
      BorderRadius.all(Radius.circular(sm));

  static const BorderRadius pillRadius =
      BorderRadius.all(Radius.circular(pill));

  static const BorderRadius sheetRadius = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
}

// shadows
abstract final class AppShadows {
  /// Default card shadow: `0 2px 12px rgba(0,0,0,0.06)`
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  // elevated shadow for FAB and bottom sheets
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // border-like shadow
  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}