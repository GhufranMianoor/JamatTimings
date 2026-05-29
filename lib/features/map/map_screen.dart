import 'package:flutter/material.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/widgets/islamic_pattern_bg.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Masjid Map Explorer', style: theme.textTheme.titleLarge),
      ),
      body: IslamicPatternBackground(
        opacity: 0.03,
        child: Stack(
          children: [
            // Map Placeholder Mock UI
            Container(
              color: colorScheme.surface.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 80, color: colorScheme.primary.withValues(alpha: 0.75)),
                    const SizedBox(height: 16),
                    Text(
                      'Interactive Google Map',
                      style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Shows nearby approved masjids on a live map coordinate layout. Requires Google Maps API Key setup.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.72)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating overlay cards for nearest mosques
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MockData.masjids.map((masjid) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                masjid.name,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                masjid.address,
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.72)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Next Jamat: ISHA 20:45',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push('/masjid/${masjid.id}'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('View Timings'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
