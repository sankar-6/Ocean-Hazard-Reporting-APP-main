import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance!;

  static Future<void> initialize() async {
    _instance = LocationService();
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await Permission.location.request();
      if (permission != PermissionStatus.granted) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Unknown location';
    }
  }

  Future<List<Placemark>> getPlacemarksFromCoordinates(double lat, double lng) async {
    try {
      return await placemarkFromCoordinates(lat, lng);
    } catch (e) {
      return [];
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
