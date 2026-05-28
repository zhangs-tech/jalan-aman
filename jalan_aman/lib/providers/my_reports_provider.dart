import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/services/report_service.dart';

class MyReportsState {
  const MyReportsState({
    this.items = const <ReportSummary>[],
    this.nextCursor,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.reportType,
  });

  final List<ReportSummary> items;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? reportType;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  MyReportsState copyWith({
    List<ReportSummary>? items,
    String? nextCursor,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? reportType,
    bool clearError = false,
    bool clearNextCursor = false,
  }) {
    return MyReportsState(
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      reportType: reportType ?? this.reportType,
    );
  }
}

class MyReportsNotifier extends StateNotifier<MyReportsState> {
  MyReportsNotifier() : super(const MyReportsState()) {
    loadInitial();
  }

  Future<void> setReportType(String? reportType) async {
    state = state.copyWith(
      reportType: reportType,
      items: const <ReportSummary>[],
      clearNextCursor: true,
      clearError: true,
    );
    await loadInitial();
  }

  Future<void> loadInitial() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await ReportService.getMyReports(
        reportType: state.reportType,
      );
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> loadMore() async {
    if (!mounted || state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await ReportService.getMyReports(
        cursor: state.nextCursor,
        reportType: state.reportType,
      );
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        items: <ReportSummary>[...state.items, ...page.items],
        nextCursor: page.nextCursor,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false, error: error.toString());
    }
  }
}

final myReportsProvider =
    StateNotifierProvider.autoDispose<MyReportsNotifier, MyReportsState>(
      (ref) => MyReportsNotifier(),
    );
