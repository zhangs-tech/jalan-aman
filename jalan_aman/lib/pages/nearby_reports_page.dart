import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/components/card.dart';
import 'package:jalan_aman/components/report_card.dart';
import 'package:jalan_aman/components/report_type_filter_row.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/pages/create_report_page.dart';
import 'package:jalan_aman/pages/report_detail_page.dart';
import 'package:jalan_aman/providers/location_providers.dart';
import 'package:jalan_aman/providers/public_reports_provider.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:jalan_aman/utils/report_refresh.dart';
import 'package:jalan_aman/utils/time_label.dart';

class NearbyReportsPage extends ConsumerStatefulWidget {
  const NearbyReportsPage({super.key});

  @override
  ConsumerState<NearbyReportsPage> createState() => _NearbyReportsPageState();
}

class _NearbyReportsPageState extends ConsumerState<NearbyReportsPage> {
  final ScrollController _scrollController = ScrollController();
  ReportType? _selectedType;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(publicReportsProvider.notifier).loadMore();
    }
  }

  Future<void> _openCreateReport() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateReportPage()),
    );
    if (created == true) {
      await refreshReportFeeds(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentPositionProvider);
    final state = ref.watch(publicReportsProvider);

    locationAsync.whenData((pos) {
      if (pos != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref
              .read(publicReportsProvider.notifier)
              .setCenter(latitude: pos.latitude, longitude: pos.longitude);
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Nearby',
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
      ),
      body: Column(
        children: [
          ReportTypeFilterRow(
            selectedType: _selectedType,
            onSelected: (type) {
              setState(() => _selectedType = type);
              ref
                  .read(publicReportsProvider.notifier)
                  .setReportType(type?.value);
            },
          ),
          _RadiusControl(
            radiusKm: state.radiusKm,
            onChanged: (value) =>
                ref.read(publicReportsProvider.notifier).setRadius(value),
          ),
          Expanded(
            child: _ReportList(
              state: state,
              scrollController: _scrollController,
              onRefresh: () =>
                  ref.read(publicReportsProvider.notifier).loadInitial(),
              onLoadMore: () =>
                  ref.read(publicReportsProvider.notifier).loadMore(),
              onCreateReport: _openCreateReport,
              onOpenReport: (reportId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportDetailPage(reportId: reportId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onCreateReport,
    required this.onOpenReport,
  });

  final PublicReportsState state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onCreateReport;
  final ValueChanged<String> onOpenReport;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.items.isEmpty) {
      return const _LoadingList();
    }
    if (state.error != null && state.items.isEmpty) {
      return _ErrorState(message: state.error!, onRetry: onRefresh);
    }
    if (state.items.isEmpty) {
      final message = state.hasCenter
          ? 'No nearby public reports in ${state.radiusKm.toStringAsFixed(0)} km radius.'
          : 'No active public reports found.';
      return _EmptyState(
        message: message,
        ctaLabel: 'Create Report',
        onPressed: onCreateReport,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final item = state.items[index];
          final label = item.distanceKm.isFinite
              ? '${item.distanceKm.toStringAsFixed(1)} km - ${timeAgoLabel(item.report.createdAt)}'
              : timeAgoLabel(item.report.createdAt);
          return ReportCard(
            report: item.report,
            trailingLabel: label,
            onTap: () => onOpenReport(item.report.id),
          );
        },
      ),
    );
  }
}

class _RadiusControl extends StatefulWidget {
  const _RadiusControl({required this.radiusKm, required this.onChanged});

  final double radiusKm;
  final ValueChanged<double> onChanged;

  @override
  State<_RadiusControl> createState() => _RadiusControlState();
}

class _RadiusControlState extends State<_RadiusControl> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.radiusKm;
  }

  @override
  void didUpdateWidget(covariant _RadiusControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.radiusKm != widget.radiusKm) {
      _value = widget.radiusKm;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.xs,
      ),
      child: Cards(
        appSpacing: Spacing.sm,
        border: Border.all(color: AppColors.border),
        boxShadow: const [],
        child: Row(
          children: [
            const Icon(
              Icons.near_me_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${_value.toStringAsFixed(0)} km',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Slider(
                value: _value,
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (value) => setState(() => _value = value),
                onChangeEnd: widget.onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => Cards(
        height: 120,
        appSpacing: Spacing.xs,
        border: Border.all(color: AppColors.border),
        boxShadow: const [],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load reports', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.base),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.ctaLabel,
    required this.onPressed,
  });

  final String message;
  final String ctaLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.base),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.base),
            FilledButton(onPressed: onPressed, child: Text(ctaLabel)),
          ],
        ),
      ),
    );
  }
}
