import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/models/map_bounds.dart';
import 'package:jalan_aman/providers/map_pins_provider.dart';
import 'package:jalan_aman/providers/my_reports_provider.dart';
import 'package:jalan_aman/providers/public_reports_provider.dart';

Future<void> refreshReportFeeds(
  WidgetRef ref, {
  MapBoundsModel? mapBounds,
}) async {
  if (mapBounds != null) {
    ref.invalidate(mapPinsProvider(mapBounds));
  }
  await ref.read(myReportsProvider.notifier).loadInitial();
  await ref.read(publicReportsProvider.notifier).loadInitial();
}
