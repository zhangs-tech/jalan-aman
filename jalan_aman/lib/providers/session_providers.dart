import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/providers/map_pins_provider.dart';
import 'package:jalan_aman/providers/my_reports_provider.dart';
import 'package:jalan_aman/providers/profile_providers.dart';
import 'package:jalan_aman/providers/public_reports_provider.dart';

void invalidateSessionScopedProviders(WidgetRef ref) {
  ref.invalidate(userProfileProvider);
  ref.invalidate(myReportsProvider);
  ref.invalidate(publicReportsProvider);
  ref.invalidate(mapPinsProvider);
}
