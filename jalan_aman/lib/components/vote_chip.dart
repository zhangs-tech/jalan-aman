import 'package:flutter/material.dart';
import 'package:jalan_aman/theme/theme.dart';

class VoteChip extends StatelessWidget {
  const VoteChip({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    this.active = false,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool active;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;
    final bg = active ? chipColor : AppColors.surfaceVariant;
    final fg = active ? Colors.white : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
            color: active ? chipColor : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$label $count',
              style: AppTextStyles.labelSmall.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
