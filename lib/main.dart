import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamat_timings/app/app.dart';
import 'package:jamat_timings/data/models/masjid.dart';
import 'package:jamat_timings/data/models/prayer_timing.dart';
import 'package:jamat_timings/core/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Environment Variables (.env) if present, else fallback quietly
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // In production/CI without .env, we can configure fallback keys
  }

  // Initialize Hive Offline Storage
  await Hive.initFlutter();
  
  // Register Hive Type Adapters
  Hive.registerAdapter(MasjidAdapter());
  Hive.registerAdapter(PrayerTimingAdapter());

  // Open Hive Storage boxes
  await Hive.openBox<Masjid>(AppConstants.masjidsBox);
  await Hive.openBox<PrayerTiming>(AppConstants.timingsBox);
  await Hive.openBox<String>(AppConstants.favouritesBox);
  await Hive.openBox(AppConstants.metadataBox);

  // Initialize Supabase Client
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://mock-project.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'mock-anon-key';

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (_) {
    // Handle mock initialization if keys are blank
  }

  runApp(
    const ProviderScope(
      child: JamatTimingsApp(),
    ),
  );
}
