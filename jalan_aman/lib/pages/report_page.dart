import 'package:flutter/material.dart';
import 'package:jalan_aman/components/card.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/theme/theme.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];
  ReportType? _selectedReportType;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);

    // TODO: replace with real API call
    // final result = await ReportService.getMyReports();
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _reports = [
        {
          'id': '1',
          'description':
              'Lubang besar di lajur kiri, bahaya untuk pengendara motor.',
          'address': 'Jl. Sudirman, Jakarta Pusat',
          'reportType': 'pothole',
          'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'id': '2',
          'description': 'Lampu jalan tidak menyala sejak 3 hari lalu.',
          'address': 'Jl. Thamrin, Jakarta Pusat',
          'reportType': 'broken_traffic_light',
          'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
        },
        {
          'id': '3',
          'description': 'Got sudah diperbaiki oleh petugas.',
          'address': 'Jl. Gatot Subroto, Jakarta',
          'reportType': 'flood',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '4',
          'description': 'Kecelakaan mobil di perempatan.',
          'address': 'Jl. Kuningan, Jakarta Selatan',
          'reportType': 'accident',
          'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
        },
        {
          'id': '5',
          'description': 'Ada polisi mengatur lalu lintas.',
          'address': 'Jl. Rasuna Said, Jakarta Selatan',
          'reportType': 'police',
          'createdAt': DateTime.now().subtract(const Duration(minutes: 30)),
        },
      ];
    });
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_selectedReportType == null) return _reports;
    final typeValue = _selectedReportType!.value;
    return _reports
        .where((report) => report['reportType'] == typeValue)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _filteredReports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchReports,
          ),
        ],
      ),
      body: Column(
        children: [
          _ReportTypeFilterRow(
            selectedType: _selectedReportType,
            onSelected: (type) {
              setState(() => _selectedReportType = type);
            },
          ),
          Expanded(
            child: _isLoading
                ? const _LoadingList()
                : filteredReports.isEmpty
                    ? _selectedReportType != null
                        ? _FilteredEmptyState(
                            label: _selectedReportType!.label,
                            onClear: () {
                              setState(() => _selectedReportType = null);
                            },
                          )
                        : const _EmptyState()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _fetchReports,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          itemCount: filteredReports.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (_, i) => _ReportCard(
                            report: filteredReports[i],
                            onTap: () {
                              // TODO: Navigator.pushNamed(context, '/reports/${filteredReports[i]['id']}');
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReportTypeFilterRow extends StatelessWidget {
  const _ReportTypeFilterRow({
    required this.selectedType,
    required this.onSelected,
  });

  final ReportType? selectedType;
  final ValueChanged<ReportType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final types = <ReportType?>[null, ...ReportType.values];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.xs,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: types
              .map(
                (type) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _TypeFilterPill(
                    type: type,
                    isSelected: type == selectedType,
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

class _TypeFilterPill extends StatelessWidget {
  const _TypeFilterPill({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final ReportType? type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isAll = type == null;
    final Color background = isAll
        ? AppColors.surfaceVariant
        : type!.color.withValues(alpha: 0.12);
    final Color foreground =
        isAll ? AppColors.textSecondary : type!.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
            color: isSelected ? foreground : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Text(
          isAll ? 'All' : type!.label,
          style: AppTextStyles.labelSmall.copyWith(
            color: foreground,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});

  final Map<String, dynamic> report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reportType = ReportType.fromString(report['reportType']);
    final createdAt = report['createdAt'] as DateTime? ?? DateTime.now();

    return GestureDetector(
      onTap: onTap,
      child: Cards(
        appSpacing: Spacing.base,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: reportType.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.inputRadius,
              ),
              child: Icon(
                reportType.icon,
                color: reportType.color,
                size: 28,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _ReportTypeBadge(reportType: reportType),
                      const Spacer(),
                      Text(
                        _timeAgo(createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    reportType.label,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          report['address'],
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ReportTypeBadge extends StatelessWidget {
  const _ReportTypeBadge({required this.reportType});

  final ReportType reportType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: reportType.color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        reportType.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: reportType.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 8,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Cards(
      height: 105,
      appSpacing: Spacing.base,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: AppRadius.inputRadius,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(height: 12, width: 80, color: AppColors.divider),
                Container(
                  height: 14,
                  width: double.infinity,
                  color: AppColors.divider,
                ),
                Container(height: 11, width: 120, color: AppColors.divider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty States ──────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.base),
          Text('There are no reports yet', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'The reports you create will appear here.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_alt_off, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.base),
          Text('No reports for $label', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try another type or clear the filter.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.base),
          TextButton(onPressed: onClear, child: const Text('Clear filter')),
        ],
      ),
    );
  }
}
