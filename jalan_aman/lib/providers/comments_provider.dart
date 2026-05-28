import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/services/comment_service.dart';

class CommentsState {
  const CommentsState({
    this.items = const <ReportComment>[],
    this.nextCursor,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.error,
  });

  final List<ReportComment> items;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSubmitting;
  final String? error;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  CommentsState copyWith({
    List<ReportComment>? items,
    String? nextCursor,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return CommentsState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  CommentsNotifier(this._reportId) : super(const CommentsState()) {
    loadInitial();
  }

  final String _reportId;

  Future<void> loadInitial() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await CommentService.getByReportId(reportId: _reportId);
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!mounted || state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page = await CommentService.getByReportId(
        reportId: _reportId,
        cursor: state.nextCursor,
      );
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        items: <ReportComment>[...state.items, ...page.items],
        nextCursor: page.nextCursor,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        error: error.toString(),
      );
    }
  }

  Future<void> addComment(String details) async {
    if (!mounted) return;
    if (details.trim().isEmpty) return;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final comment = await CommentService.create(
        reportId: _reportId,
        details: details.trim(),
      );
      if (!mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        items: <ReportComment>[comment, ...state.items],
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        error: error.toString(),
      );
    }
  }

  Future<void> updateComment({
    required String commentId,
    required String details,
  }) async {
    if (!mounted) return;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final updated = await CommentService.update(
        reportId: _reportId,
        commentId: commentId,
        details: details,
      );
      if (!mounted) return;
      final next = state.items
          .map((item) => item.id == commentId ? updated : item)
          .toList();
      state = state.copyWith(
        isSubmitting: false,
        items: next,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        error: error.toString(),
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    if (!mounted) return;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await CommentService.delete(
        reportId: _reportId,
        commentId: commentId,
      );
      if (!mounted) return;
      final next = state.items.where((item) => item.id != commentId).toList();
      state = state.copyWith(
        isSubmitting: false,
        items: next,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        error: error.toString(),
      );
    }
  }
}

final commentsProvider =
    StateNotifierProvider.autoDispose
        .family<CommentsNotifier, CommentsState, String>(
  (ref, reportId) => CommentsNotifier(reportId),
);
