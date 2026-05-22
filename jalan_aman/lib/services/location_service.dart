import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  static Future<LocationPermission?> checkLocationService() async {
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return null;
    }

    return permission;
  }

  static Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await checkLocationService();
    if (serviceEnabled == null) {
      return null;
    }
    return await Geolocator.getCurrentPosition(
      locationSettings: LocationService.locationSettings,
    );
  }

  //Check location manually before call getLivePosition()
  static Stream<Position>? getLivePosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }
}
