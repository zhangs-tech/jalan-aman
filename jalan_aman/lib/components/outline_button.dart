import 'package:flutter/material.dart';
import 'package:jalan_aman/theme/theme.dart';

class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.loadingLabel,
    this.color = AppColors.danger,
    this.height = 52,
  });

  final String label;
  final String? loadingLabel;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final text = isLoading ? (loadingLabel ?? label) : label;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.pillRadius,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
    );
  }
}
