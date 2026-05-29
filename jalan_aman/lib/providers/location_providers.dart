import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalan_aman/services/address_service.dart';
import 'package:jalan_aman/services/location_service.dart';
import 'package:latlong2/latlong.dart';

final currentPositionProvider = StreamProvider<LatLng?>((ref) async* {
  final position = await LocationService.getCurrentLocation();
  if (position == null) {
    yield null;
    return;
  }

  yield LatLng(position.latitude, position.longitude);

  final livePositions = LocationService.getLivePosition();
  if (livePositions == null) return;

  await for (final position in livePositions) {
    yield LatLng(position.latitude, position.longitude);
  }
});

final addressFromPositionProvider =
    FutureProvider.family<AddressResult?, LatLng>((ref, position) async {
      return AddressService.getAddress(position.latitude, position.longitude);
    });
