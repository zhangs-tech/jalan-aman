import 'package:flutter/material.dart';
import 'package:jalan_aman/theme/theme.dart';

enum Spacing { xs, sm, md, base, lg, xl, xxl, xxxl }

class Cards extends StatelessWidget {
  const Cards({
    super.key,
    this.width,
    this.height,
    this.appSpacing = Spacing.xl,
    this.padding,
    this.color = AppColors.surface,
    this.borderRadius = AppRadius.cardRadius,
    this.border,
    this.boxShadow = AppShadows.card,
    this.child,
  });

  final double? width;
  final double? height;
  final Spacing appSpacing;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final BorderRadius borderRadius;
  final Border? border;
  final List<BoxShadow> boxShadow;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(_appSpacing),
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
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
