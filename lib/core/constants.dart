import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Jamat Timings';
  static const String appVersion = '1.0.0';

  // Offline Caching constants
  static const double defaultRadiusKm = 10.0;
  static const int maxCacheSizeInBytes = 50 * 1024 * 1024; // 50 MB
  static const Duration staleCacheThreshold = Duration(hours: 24);
  static const int lruCacheLimit = 50;

  // Hive Box Names
  static const String masjidsBox = 'masjids_box';
  static const String timingsBox = 'timings_box';
  static const String favouritesBox = 'favourites_box';
  static const String metadataBox = 'metadata_box';

  // Prayer configuration
  static const List<String> prayerNames = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  static const Map<String, String> prayerDisplayNames = {
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
    'jumuah': 'Jumu\'ah',
    'taraweeh': 'Taraweeh',
    'eid': 'Eid Prayer',
  };

  static const Map<String, IconData> prayerIcons = {
    'fajr': Icons.wb_twilight,
    'dhuhr': Icons.wb_sunny,
    'asr': Icons.wb_sunny_outlined,
    'maghrib': Icons.nightlight_round,
    'isha': Icons.nights_stay,
    'jumuah': Icons.mosque,
    'taraweeh': Icons.star_border_outlined,
    'eid': Icons.celebration,
  };
}
