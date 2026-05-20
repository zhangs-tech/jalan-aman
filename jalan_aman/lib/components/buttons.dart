import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum ButtonType {
  primary,
  secondary,
  inverted,
  outlined,
}

class Buttons extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final ButtonType type;

  const Buttons({
    super.key,
    required this.onPressed,
    required this.label,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: switch (type) {
        ButtonType.outlined => OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: _backgroundColor,
              foregroundColor: _foregroundColor,
              side: const BorderSide(color: AppColors.borderStrong),
              elevation: 0,
              textStyle: AppTextStyles.button,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.pillRadius,
              ),
            ),
            child: Text(label),
          ),
        _ => ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _backgroundColor,
              foregroundColor: _foregroundColor,
              elevation: 0,
              textStyle: AppTextStyles.button,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.pillRadius,
              ),
            ),
            child: Text(label),
          ),
      },
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case ButtonType.primary:
        return AppColors.accent;
      case ButtonType.secondary:
        return AppColors.surfaceVariant;
      case ButtonType.inverted:
        return AppColors.primaryDark;
      case ButtonType.outlined:
        return AppColors.surface;
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.inverted:
        return AppColors.textInverse;
      case ButtonType.secondary:
      case ButtonType.outlined:
        return AppColors.textPrimary;
    }
  }
}
