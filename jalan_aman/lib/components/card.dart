import 'package:flutter/material.dart';
import 'package:jalan_aman/theme/theme.dart';

enum Spacing { xs, sm, md, base, lg, xl, xxl, xxxl }

class Cards extends StatelessWidget {
  const Cards({
    super.key,
    this.height,
    this.appSpacing = Spacing.xl,
    this.child,
  });

  final double? height;
  final Spacing appSpacing;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(_appSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.cardRadius,
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }

  double get _appSpacing {
    switch (appSpacing) {
      case Spacing.xs:
        return AppSpacing.xs;
      case Spacing.sm:
        return AppSpacing.sm;
      case Spacing.md:
        return AppSpacing.md;
      case Spacing.base:
        return AppSpacing.base;
      case Spacing.lg:
        return AppSpacing.lg;
      case Spacing.xl:
        return AppSpacing.xl;
      case Spacing.xxl:
        return AppSpacing.xxl;
      case Spacing.xxxl:
        return AppSpacing.xxxl;
    }
  }
}
