import 'package:flutter/material.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/theme/theme.dart';

class ReportTypeBadge extends StatelessWidget {
  const ReportTypeBadge({
    super.key,
    required this.reportType,
    this.compact = false,
  });

  final ReportType reportType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: reportType.color.withValues(alpha: 0.14),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reportType.icon,
            size: compact ? 12 : 14,
            color: reportType.color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            reportType.label,
            style: (compact ? AppTextStyles.labelSmall : AppTextStyles.labelMedium)
                .copyWith(
              color: reportType.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
