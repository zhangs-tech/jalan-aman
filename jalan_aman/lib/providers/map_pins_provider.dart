import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/models/map_bounds.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/services/report_service.dart';

final mapPinsProvider =
    FutureProvider.family<List<MapPinModel>, MapBoundsModel>((ref, bounds) {
  return ReportService.getMapPins(bounds);
});
