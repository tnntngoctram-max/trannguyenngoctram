import 'package:geolocator/geolocator.dart';

/// Lấy tọa độ GPS & Kiểm tra vị trí
class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  bool isWithinRadius({
    required double userLat,
    required double userLng,
    required double targetLat,
    required double targetLng,
    required double radiusMeters,
  }) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      targetLat,
      targetLng,
    );
    return distanceInMeters <= radiusMeters;
  }
}
