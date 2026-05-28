import 'package:flutter/material.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/theme/theme.dart';

class ReportTypeFilterRow extends StatelessWidget {
  const ReportTypeFilterRow({
    super.key,
    required this.selectedType,
    required this.onSelected,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.base,
      AppSpacing.base,
      AppSpacing.base,
      AppSpacing.xs,
    ),
    this.itemSpacing = AppSpacing.md,
    this.pillPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    this.animate = true,
    this.fontWeight = FontWeight.w700,
  });

  const ReportTypeFilterRow.compact({
    super.key,
    required this.selectedType,
    required this.onSelected,
  }) : padding = const EdgeInsets.only(
         left: AppSpacing.base,
         right: AppSpacing.base,
         top: AppSpacing.sm,
       ),
       itemSpacing = AppSpacing.xs,
       pillPadding = const EdgeInsets.symmetric(
         horizontal: AppSpacing.md,
         vertical: AppSpacing.xs,
       ),
       animate = false,
       fontWeight = FontWeight.w600;

  final ReportType? selectedType;
  final ValueChanged<ReportType?> onSelected;
  final EdgeInsetsGeometry padding;
  final double itemSpacing;
  final EdgeInsetsGeometry pillPadding;
  final bool animate;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final types = <ReportType?>[null, ...ReportType.values];
    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: types
              .map(
                (type) => Padding(
                  padding: EdgeInsets.only(right: itemSpacing),
                  child: _ReportTypeFilterPill(
                    type: type,
                    isSelected: selectedType == type,
                    padding: pillPadding,
                    animate: animate,
                    fontWeight: fontWeight,
                    onTap: () => onSelected(type),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ReportTypeFilterPill extends StatelessWidget {
  const _ReportTypeFilterPill({
    required this.type,
    required this.isSelected,
    required this.padding,
    required this.animate,
    required this.fontWeight,
    required this.onTap,
  });

  final ReportType? type;
  final bool isSelected;
  final EdgeInsetsGeometry padding;
  final bool animate;
  final FontWeight fontWeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAll = type == null;
    final activeColor = isAll ? AppColors.primary : type!.color;
    final decoration = BoxDecoration(
      color: isSelected ? activeColor : AppColors.surface,
      borderRadius: AppRadius.pillRadius,
      border: Border.all(color: isSelected ? activeColor : AppColors.border),
    );
    final child = Text(
      isAll ? 'All' : type!.label,
      style: AppTextStyles.labelSmall.copyWith(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: fontWeight,
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: animate
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: padding,
              decoration: decoration,
              child: child,
            )
          : Container(padding: padding, decoration: decoration, child: child),
    );
  }
}
