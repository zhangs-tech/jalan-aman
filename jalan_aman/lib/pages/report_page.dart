import 'package:flutter/material.dart';
import 'package:jalan_aman/components/card.dart';
import 'package:jalan_aman/theme/theme.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];
  String _selectedStatus = 'All';

  static const List<String> _statusFilters = [
    'All',
    'Pending',
    'In Progress',
    'Resolved',
    'Rejected',
  ];

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
          'title': 'Jalan Sudirman, Dekat Halte',
          'description':
              'Lubang besar di lajur kiri, bahaya untuk pengendara motor.',
          'address': 'Jl. Sudirman, Jakarta Pusat',
          'status': 'Pending',
          'timeAgo': '2 jam lalu',
        },
        {
          'id': '2',
          'title': 'Lampu Jalan Mati',
          'description': 'Lampu jalan tidak menyala sejak 3 hari lalu.',
          'address': 'Jl. Thamrin, Jakarta Pusat',
          'status': 'In Progress',
          'timeAgo': '1 hari lalu',
        },
        {
          'id': '3',
          'title': 'Drainase Tersumbat',
          'description': 'Got sudah diperbaiki oleh petugas.',
          'address': 'Jl. Gatot Subroto, Jakarta',
          'status': 'Resolved',
          'timeAgo': '3 hari lalu',
        },
      ];
    });
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_selectedStatus == 'All') {
      return _reports;
    }

    final selected = _selectedStatus.toLowerCase();
    return _reports
        .where(
          (report) => (report['status'] as String).toLowerCase() == selected,
        )
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
          _StatusFilterRow(
            statuses: _statusFilters,
            selectedStatus: _selectedStatus,
            onSelected: (status) {
              setState(() => _selectedStatus = status);
            },
          ),
          Expanded(
            child: _isLoading
                ? const _LoadingList()
                : filteredReports.isEmpty
                ? _reports.isEmpty
                      ? const _EmptyState()
                      : _FilteredEmptyState(
                          status: _selectedStatus,
                          onClear: () {
                            setState(() => _selectedStatus = 'All');
                          },
                        )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _fetchReports,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      itemCount: filteredReports.length,
                      separatorBuilder: (_, __) =>
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

class _StatusFilterRow extends StatelessWidget {
  const _StatusFilterRow({
    required this.statuses,
    required this.selectedStatus,
    required this.onSelected,
  });

  final List<String> statuses;
  final String selectedStatus;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
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
          children: statuses
              .map(
                (status) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: _StatusFilterPill(
                    status: status,
                    isSelected: status == selectedStatus,
                    onTap: () => onSelected(status),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StatusFilterPill extends StatelessWidget {
  const _StatusFilterPill({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final String status;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isAll = status == 'All';
    final Color background = isAll
        ? AppColors.surfaceVariant
        : AppColors.statusBackground(status);
    final Color foreground = isAll
        ? AppColors.textSecondary
        : AppColors.statusForeground(status);

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
          status,
          style: AppTextStyles.labelSmall.copyWith(
            color: foreground,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Report Card ──────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});

  final Map<String, dynamic> report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Cards(
        appSpacing: Spacing.base,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadius.inputRadius,
              ),
              child: const Icon(
                Icons.add_road_rounded,
                color: AppColors.textTertiary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // status n time
                  Row(
                    children: [
                      _StatusBadge(status: report['status']),
                      const Spacer(),
                      Text(report['timeAgo'], style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // title
                  Text(
                    report['title'],
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // address
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

            // Chevron
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
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.statusBackground(status),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.statusForeground(status),
          fontWeight: FontWeight.w600,
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
          // Thumbnail skeleton
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

// ── Empty State ───────────────────────────────────────────────────
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
  const _FilteredEmptyState({required this.status, required this.onClear});

  final String status;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_alt_off, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.base),
          Text('No reports for $status', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try another status or clear the filter.',
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
