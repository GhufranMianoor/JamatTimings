import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  shadows: const [
                    Shadow(offset: Offset(1, 1), blurRadius: 4.0, color: Colors.black45),
                  ],
                ),
              ),
              background: Container(
                color: colorScheme.primary,
                child: IslamicPatternBackground(
                  opacity: 0.1,
                  child: Center(
                    child: Icon(
                      Icons.mosque,
                      size: 64,
                      color: colorScheme.secondary,
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
                        Icon(Icons.location_on, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                masjid.address,
                                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              if (masjid.area != null)
                                Text(
                                  '${masjid.area}, ${masjid.city}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Icon(Icons.sync, color: colorScheme.onSurface.withValues(alpha: 0.55), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Last updated: 1 day ago',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Standard Prayer Timings List
                    Text(
                      'Daily Jamat Schedule',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
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
                    Text(
                      'Special Congregated Timings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
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
                      icon: Icons.star_border,
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
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: Icon(Icons.directions, color: colorScheme.onPrimary),
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
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (timings.isNotEmpty)
                    ...timings.map((t) => Text(
                          t,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ))
                  else
                    Text(
                      fallback ?? 'No timings scheduled',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
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
