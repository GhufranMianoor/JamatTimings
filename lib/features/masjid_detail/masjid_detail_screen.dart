import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/core/constants.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/widgets/islamic_pattern_bg.dart';
import 'package:jamat_timings/widgets/prayer_time_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class MasjidDetailScreen extends ConsumerStatefulWidget {
  final String masjidId;

  const MasjidDetailScreen({super.key, required this.masjidId});

  @override
  ConsumerState<MasjidDetailScreen> createState() => _MasjidDetailScreenState();
}

class _MasjidDetailScreenState extends ConsumerState<MasjidDetailScreen> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    // Default mock check
    _isFavourite = widget.masjidId == 'm1';
  }

  Future<void> _openInMaps(double lat, double lng, String name) async {
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$name&ll=$lat,$lng');

    try {
      if (await launchUrl(googleMapsUrl)) {
        // Success
      } else if (await launchUrl(appleMapsUrl)) {
        // Success
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open map coordinates')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error launching map application')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find masjid in mock data
    final masjid = MockData.masjids.firstWhere(
      (m) => m.id == widget.masjidId,
      orElse: () => MockData.masjids[0],
    );

    // Get timings for this masjid
    final masjidTimings = MockData.timings[widget.masjidId] ?? [];
    
    // Sort standard prayers
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Elegant Header Sliver App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                masjid.name,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  shadows: [
                    Shadow(offset: Offset(1, 1), blurRadius: 4.0, color: Colors.black54),
                  ],
                ),
              ),
              background: Container(
                color: AppTheme.primaryGreen,
                child: const IslamicPatternBackground(
                  opacity: 0.1,
                  child: Center(
                    child: Icon(
                      Icons.mosque,
                      size: 64,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isFavourite ? Icons.star : Icons.star_border),
                onPressed: () {
                  setState(() {
                    _isFavourite = !_isFavourite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isFavourite ? 'Added to Favourites' : 'Removed from Favourites',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          // Details List
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Address and Meta Block
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                masjid.address,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              if (masjid.area != null)
                                Text(
                                  '${masjid.area}, ${masjid.city}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        const Icon(Icons.sync, color: Colors.grey, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Last updated: 1 day ago',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Standard Prayer Timings List
                    const Text(
                      'Daily Jamat Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...prayers.map((prayer) {
                      // Get all times for this specific prayer
                      final times = masjidTimings
                          .where((t) => t.prayer.toLowerCase() == prayer)
                          .map((t) => t.jamatTime)
                          .toList();

                      // Fajr is next for demo
                      final isNext = prayer == 'fajr';

                      return PrayerTimeTile(
                        prayerName: prayer,
                        jamatTimes: times,
                        isNext: isNext,
                      );
                    }),

                    const Divider(height: 32),

                    // Special Timings Section
                    const Text(
                      'Special Congregated Timings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Jumuah Tile
                    _buildSpecialTile(
                      context: context,
                      title: 'Jumu\'ah (Friday Prayer)',
                      icon: Icons.mosque,
                      timings: masjidTimings
                          .where((t) => t.prayer.toLowerCase() == 'jumuah')
                          .map((t) => '${t.label ?? "Prayer"}: ${t.jamatTime}')
                          .toList(),
                    ),

                    // Taraweeh Tile
                    _buildSpecialTile(
                      context: context,
                      title: 'Taraweeh (Ramadan)',
                      icon: Icons.star_border_purple_500,
                      timings: masjidTimings
                          .where((t) => t.prayer.toLowerCase() == 'taraweeh')
                          .map((t) => 'Taraweeh: ${t.jamatTime}')
                          .toList(),
                      fallback: 'Scheduled during Ramadan only',
                    ),

                    const SizedBox(height: 32),

                    // Navigation Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.directions, color: Colors.white),
                            label: const Text('Open in Google Maps'),
                            onPressed: () => _openInMaps(masjid.latitude, masjid.longitude, masjid.name),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<String> timings,
    String? fallback,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (timings.isNotEmpty)
                    ...timings.map((t) => Text(t, style: const TextStyle(fontSize: 13, color: Colors.black87)))
                  else
                    Text(
                      fallback ?? 'No timings scheduled',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
