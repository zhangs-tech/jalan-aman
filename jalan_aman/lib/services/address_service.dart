import 'package:geocoding/geocoding.dart';

typedef AddressResult = ({String address, String zipCode});

class AddressService {
  static Future<AddressResult?> getAddress(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final address = [
        place.street,
        place.subLocality,
        place.locality,
      ].where((p) => p != null && p.isNotEmpty).join(', ');

      return (address: address, zipCode: place.postalCode ?? '6767');
    } catch (_) {
      return null;
    }
  }
}
