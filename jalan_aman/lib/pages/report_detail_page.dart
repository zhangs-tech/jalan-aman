import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/components/comment_input.dart';
import 'package:jalan_aman/components/comment_item.dart';
import 'package:jalan_aman/components/report_type_badge.dart';
import 'package:jalan_aman/components/vote_chip.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/models/report_type.dart';
import 'package:jalan_aman/providers/comments_provider.dart';
import 'package:jalan_aman/providers/profile_providers.dart';
import 'package:jalan_aman/providers/report_detail_provider.dart';
import 'package:jalan_aman/services/location_service.dart';
import 'package:jalan_aman/services/report_service.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:jalan_aman/utils/time_label.dart';

class ReportDetailPage extends ConsumerStatefulWidget {
  const ReportDetailPage({super.key, required this.reportId});

  final String reportId;

  @override
  ConsumerState<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends ConsumerState<ReportDetailPage> {
  bool _isVoting = false;
  bool _isDeleting = false;
  bool _isEditing = false;

  Future<void> _vote({required String type, required bool isAuthor}) async {
    if (_isVoting || isAuthor) return;
    setState(() => _isVoting = true);
    try {
      if (type == 'confirm') {
        await ReportService.confirm(widget.reportId);
      } else {
        await ReportService.resolve(widget.reportId);
      }
      ref.invalidate(reportDetailProvider(widget.reportId));
    } on ReportServiceException catch (error) {
      if (!mounted) return;
      final votedRecently = error.statusCode == 409 || error.statusCode == 422;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            votedRecently ? 'You already voted recently' : error.message,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isVoting = false);
    }
  }

  Future<void> _confirmDelete() async {
    if (_isDeleting) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This will remove your report from the feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    setState(() => _isDeleting = true);
    try {
      await ReportService.delete(widget.reportId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report deleted')));
    } on ReportServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _showEditDialog(ReportDetail report) async {
    if (_isEditing) return;
    final descriptionController = TextEditingController(
      text: report.description,
    );
    final addressController = TextEditingController(text: report.address);
    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: addressController,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  maxLength: 256,
                  style: AppTextStyles.bodyMedium,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (shouldSave != true) return;
      setState(() => _isEditing = true);
      final current = await LocationService.getCurrentLocation();
      if (current == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location unavailable for edit check')),
        );
        return;
      }
      await ReportService.edit(
        reportId: report.id,
        description: descriptionController.text.trim(),
        address: addressController.text.trim(),
        userLat: current.latitude,
        userLng: current.longitude,
      );
      ref.invalidate(reportDetailProvider(widget.reportId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report updated')));
    } on ReportServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      descriptionController.dispose();
      addressController.dispose();
      if (mounted) setState(() => _isEditing = false);
    }
  }

  Future<void> _confirmDeleteComment({
    required String reportId,
    required String commentId,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await ref
          .read(commentsProvider(reportId).notifier)
          .deleteComment(commentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(reportDetailProvider(widget.reportId));
    final commentsState = ref.watch(commentsProvider(widget.reportId));
    final currentUserId =
        ref.watch(userProfileProvider).valueOrNull?['userId'] ?? '';

    return reportAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(error.toString(), style: AppTextStyles.bodyMedium),
        ),
      ),
      data: (state) {
        final report = state.report;
        final type = ReportType.fromString(report.reportType);
        final isAuthor =
            currentUserId.isNotEmpty && currentUserId == report.reportedBy;
        final expiresLabel = expiresInLabel(report.expiresAt);
        final commentCount = commentsState.items.length > report.commentCount
            ? commentsState.items.length
            : report.commentCount;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(type.label),
            actions: [
              if (isAuthor)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(report);
                    } else if (value == 'delete') {
                      _confirmDelete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          bottomNavigationBar: CommentInput(
            isSending: commentsState.isSubmitting,
            onSend: (value) async {
              await ref
                  .read(commentsProvider(widget.reportId).notifier)
                  .addComment(value);
              ref.invalidate(reportDetailProvider(widget.reportId));
            },
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(reportDetailProvider(widget.reportId));
              await ref
                  .read(commentsProvider(widget.reportId).notifier)
                  .loadInitial();
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.base),
              children: [
                _HeroSection(
                  imageUrl: state.imageUrl,
                  authHeaders: state.authHeaders,
                  reportType: type,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReportTypeBadge(reportType: type),
                      const SizedBox(height: AppSpacing.sm),
                      Text(report.address, style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.xs),
                      Text(report.description, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Reported ${timeAgoLabel(report.createdAt)}',
                        style: AppTextStyles.caption,
                      ),
                      if (expiresLabel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          expiresLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: VoteChip(
                          icon: Icons.thumb_up_alt_outlined,
                          label: 'Confirm',
                          count: report.voteSummary.confirms,
                          active: report.voteSummary.userVoted == 'confirm',
                          onTap: isAuthor || _isVoting
                              ? null
                              : () =>
                                    _vote(type: 'confirm', isAuthor: isAuthor),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: VoteChip(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Resolve',
                          count: report.voteSummary.resolves,
                          active: report.voteSummary.userVoted == 'resolve',
                          color: AppColors.success,
                          onTap: isAuthor || _isVoting
                              ? null
                              : () =>
                                    _vote(type: 'resolve', isAuthor: isAuthor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  child: Text(
                    'Comments ($commentCount)',
                    style: AppTextStyles.h3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (commentsState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.base),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  ...commentsState.items.map(
                    (comment) => Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        0,
                        AppSpacing.base,
                        AppSpacing.sm,
                      ),
                      child: CommentItem(
                        comment: comment,
                        isMine: comment.userId == currentUserId,
                        onDelete: () => _confirmDeleteComment(
                          reportId: widget.reportId,
                          commentId: comment.id,
                        ),
                        onUpdate: (value) => ref
                            .read(commentsProvider(widget.reportId).notifier)
                            .updateComment(
                              commentId: comment.id,
                              details: value,
                            ),
                      ),
                    ),
                  ),
                  if (commentsState.hasMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                      ),
                      child: TextButton(
                        onPressed: commentsState.isLoadingMore
                            ? null
                            : () => ref
                                  .read(
                                    commentsProvider(widget.reportId).notifier,
                                  )
                                  .loadMore(),
                        child: commentsState.isLoadingMore
                            ? const Text('Loading...')
                            : const Text('Load more comments'),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.imageUrl,
    required this.authHeaders,
    required this.reportType,
  });

  final String? imageUrl;
  final Map<String, String> authHeaders;
  final ReportType reportType;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        height: 220,
        color: reportType.color.withValues(alpha: 0.2),
        alignment: Alignment.center,
        child: Icon(reportType.icon, size: 56, color: reportType.color),
      );
    }

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Image.network(
        imageUrl!,
        headers: authHeaders,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.surfaceVariant,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (_, _, _) => Container(
          color: AppColors.surfaceVariant,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, size: 40),
        ),
      ),
    );
  }
}
