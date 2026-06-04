import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,

      // appBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.shadowColor,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 22,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.surface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(36, 4),
        showDragHandle: true,
        elevation: 8,
        modalElevation: 8,
        clipBehavior: Clip.antiAlias,
      ),

      // cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
        shadowColor: AppColors.shadowColor,
        clipBehavior: Clip.antiAlias,
      ),

      // buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.base,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.pillRadius,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.base,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.pillRadius,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
          ),
        ),
      ),

      // floating act btn
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textInverse,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        shape: CircleBorder(),
        iconSize: 24,
        sizeConstraints: BoxConstraints.tightFor(width: 52, height: 52),
      ),

      // input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        // default
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        // focus
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        // error
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTextStyles.labelMedium,
        errorStyle: AppTextStyles.caption.copyWith(
          color: AppColors.danger,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        suffixIconColor: AppColors.textSecondary,
      ),

      // chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.divider,
        labelStyle: AppTextStyles.labelSmall,
        side: const BorderSide(color: AppColors.border, width: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.pillRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        showCheckmark: false,
      ),

      // divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // list tile 
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle: AppTextStyles.bodyMedium,
        subtitleTextStyle: AppTextStyles.bodySmall,
        iconColor: AppColors.textSecondary,
        minLeadingWidth: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),

      // snackbar 
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textInverse,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
        elevation: 4,
      ),

      // progress indicator 
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.divider,
        circularTrackColor: AppColors.divider,
      ),

      // icon 
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 20,
      ),

      // text selection
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x331A6B3C),
        selectionHandleColor: AppColors.primary,
      ),

      // typography
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }

  // color scheme
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textInverse,
    primaryContainer: Color(0xFFD1EAD9),
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    onSecondary: AppColors.textInverse,
    secondaryContainer: AppColors.accentLight,
    onSecondaryContainer: AppColors.accentDark,
    error: AppColors.danger,
    onError: AppColors.textInverse,
    errorContainer: AppColors.dangerBackground,
    onErrorContainer: AppColors.danger,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    scrim: Color(0x40000000),
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.textInverse,
    inversePrimary: Color(0xFF89CFA8),
    shadow: AppColors.shadowColor,
  );
}