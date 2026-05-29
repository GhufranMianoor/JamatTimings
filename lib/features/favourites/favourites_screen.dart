import 'package:flutter/material.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/widgets/masjid_card.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Badshahi Masjid as mock favourite
    final favouriteMasjids = [MockData.masjids[0]];

    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite Masjids', style: theme.textTheme.titleLarge),
      ),
      body: favouriteMasjids.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favouriteMasjids.length,
              itemBuilder: (context, index) {
                final masjid = favouriteMasjids[index];
                return MasjidCard(
                  masjid: masjid,
                  isFavourite: true,
                  onFavouriteToggle: () {},
                  nextPrayerName: 'isha',
                  nextPrayerTime: '20:45',
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: colorScheme.primary.withValues(alpha: 0.35)),
            const SizedBox(height: 24),
            Text(
              'No Favourites Yet',
              style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Star your favorite masjids to save them here for offline access and quick reference.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
