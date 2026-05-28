import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/components/card.dart';
import 'package:jalan_aman/components/report_card.dart';
import 'package:jalan_aman/components/report_type_filter_row.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/pages/create_report_page.dart';
import 'package:jalan_aman/pages/report_detail_page.dart';
import 'package:jalan_aman/providers/my_reports_provider.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:jalan_aman/utils/report_refresh.dart';

class MyReportsPage extends ConsumerStatefulWidget {
  const MyReportsPage({super.key});

  @override
  ConsumerState<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends ConsumerState<MyReportsPage> {
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
      ref.read(myReportsProvider.notifier).loadMore();
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
    final state = ref.watch(myReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'My Reports',
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
      ),
      body: Column(
        children: [
          ReportTypeFilterRow(
            selectedType: _selectedType,
            onSelected: (type) {
              setState(() => _selectedType = type);
              ref.read(myReportsProvider.notifier).setReportType(type?.value);
            },
          ),
          Expanded(
            child: switch ((
              state.isLoading,
              state.items.isEmpty,
              state.error,
            )) {
              (true, true, _) => const _LoadingList(),
              (_, true, final String error?) => _ErrorState(
                message: error,
                onRetry: () =>
                    ref.read(myReportsProvider.notifier).loadInitial(),
              ),
              (_, true, _) => _EmptyState(
                message: "You haven't made any reports yet.",
                ctaLabel: 'Make a Report',
                onPressed: _openCreateReport,
              ),
              _ => RefreshIndicator(
                onRefresh: () =>
                    ref.read(myReportsProvider.notifier).loadInitial(),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, index) {
                    if (index >= state.items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.base,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final report = state.items[index];
                    return ReportCard(
                      report: report,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportDetailPage(reportId: report.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            },
          ),
        ],
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
              Icons.article_outlined,
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
