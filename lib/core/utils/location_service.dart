import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationProvider = FutureProvider<Position?>((ref) async {
  final service = ref.watch(locationServiceProvider);
  final hasPermission = await service.isPermissionGranted;
  if (!hasPermission) {
    final granted = await service.requestPermission();
    if (!granted) return null;
  }
  return await service.getCurrentPosition();
});

class LocationService {
  Future<Position?> getCurrentPosition() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) return null;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get isPermissionGranted async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
