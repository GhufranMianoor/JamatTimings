import 'dart:math';

class DistanceUtils {
  /// Calculates the distance in kilometers between two geographic points using the Haversine formula.
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static String formatDistance(double km) {
    if (km < 1.0) {
      final double meters = km * 1000;
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }
}
