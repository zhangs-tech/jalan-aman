import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/services/report_service.dart';
import 'package:jalan_aman/utils/distance_utils.dart';

class PublicReportsState {
  const PublicReportsState({
    this.items = const <NearbyReportItem>[],
    this.nextCursor,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.reportType,
    this.radiusKm = 5,
    this.centerLat,
    this.centerLng,
  });

  final List<NearbyReportItem> items;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String? reportType;
  final double radiusKm;
  final double? centerLat;
  final double? centerLng;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;
  bool get hasCenter => centerLat != null && centerLng != null;

  PublicReportsState copyWith({
    List<NearbyReportItem>? items,
    String? nextCursor,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? reportType,
    double? radiusKm,
    double? centerLat,
    double? centerLng,
    bool clearError = false,
    bool clearNextCursor = false,
    bool clearReportType = false,
  }) {
    return PublicReportsState(
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      reportType: clearReportType ? null : (reportType ?? this.reportType),
      radiusKm: radiusKm ?? this.radiusKm,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
    );
  }
}

class PublicReportsNotifier extends StateNotifier<PublicReportsState> {
  PublicReportsNotifier() : super(const PublicReportsState()) {
    loadInitial();
  }

  static const _nearbyPageSize = 20;
  static const _serverPageLimit = 50;

  Future<void> setCenter({
    required double latitude,
    required double longitude,
  }) async {
    final changed = state.centerLat != latitude || state.centerLng != longitude;
    state = state.copyWith(centerLat: latitude, centerLng: longitude);
    if (changed) {
      await loadInitial();
    }
  }

  Future<void> setRadius(double radiusKm) async {
    state = state.copyWith(
      radiusKm: radiusKm,
      items: const <NearbyReportItem>[],
      clearNextCursor: true,
      clearError: true,
    );
    await loadInitial();
  }

  Future<void> setReportType(String? reportType) async {
    state = state.copyWith(
      reportType: reportType,
      items: const <NearbyReportItem>[],
      clearNextCursor: true,
      clearError: true,
      clearReportType: reportType == null,
    );
    await loadInitial();
  }

  Future<void> loadInitial() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _loadNearbyPage();
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
      final page = await _loadNearbyPage(cursor: state.nextCursor);
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        items: <NearbyReportItem>[...state.items, ...page.items],
        nextCursor: page.nextCursor,
      );
    } catch (error) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false, error: error.toString());
    }
  }

  Future<CursorPage<NearbyReportItem>> _loadNearbyPage({String? cursor}) async {
    var nextCursor = cursor;
    final nearbyItems = <NearbyReportItem>[];

    do {
      final page = await ReportService.getPublicReports(
        cursor: nextCursor,
        limit: _serverPageLimit,
        reportType: state.reportType,
      );
      nearbyItems.addAll(_filterAndMap(page.items));
      nextCursor = page.nextCursor;
    } while (nearbyItems.length < _nearbyPageSize &&
        nextCursor != null &&
        nextCursor.isNotEmpty);

    return CursorPage<NearbyReportItem>(
      items: nearbyItems,
      nextCursor: nextCursor,
    );
  }

  List<NearbyReportItem> _filterAndMap(List<ReportSummary> source) {
    if (!state.hasCenter) {
      return source
          .map(
            (report) =>
                NearbyReportItem(report: report, distanceKm: double.nan),
          )
          .toList();
    }

    final filtered = <NearbyReportItem>[];
    for (final report in source) {
      final distanceKm = distanceInKm(
        startLat: state.centerLat!,
        startLng: state.centerLng!,
        endLat: report.latitude,
        endLng: report.longitude,
      );
      if (distanceKm <= state.radiusKm) {
        filtered.add(NearbyReportItem(report: report, distanceKm: distanceKm));
      }
    }
    filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return filtered;
  }
}

final publicReportsProvider =
    StateNotifierProvider.autoDispose<
      PublicReportsNotifier,
      PublicReportsState
    >((ref) => PublicReportsNotifier());
