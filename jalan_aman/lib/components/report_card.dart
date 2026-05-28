import 'package:flutter/material.dart';
import 'package:jalan_aman/components/card.dart';
import 'package:jalan_aman/components/report_type_badge.dart';
import 'package:jalan_aman/components/vote_chip.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:jalan_aman/utils/time_label.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.trailingLabel,
  });

  final ReportSummary report;
  final VoidCallback onTap;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final reportType = ReportType.fromString(report.reportType);
    return GestureDetector(
      onTap: onTap,
      child: Cards(
        appSpacing: Spacing.base,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: reportType.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(reportType.icon, color: reportType.color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ReportTypeBadge(reportType: reportType, compact: true),
                      const Spacer(),
                      Text(
                        trailingLabel ?? timeAgoLabel(report.createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    report.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      VoteChip(
                        icon: Icons.thumb_up_alt_outlined,
                        label: 'Confirm',
                        count: report.voteSummary.confirms,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      VoteChip(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Resolve',
                        count: report.voteSummary.resolves,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
