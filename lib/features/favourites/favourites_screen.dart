import 'package:flutter/material.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/widgets/masjid_card.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Badshahi Masjid as mock favourite
    final favouriteMasjids = [MockData.masjids[0]];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favourite Masjids',
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold),
        ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            const Text(
              'No Favourites Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 12),
            const Text(
              'Star your favorite masjids to save them here for offline access and quick reference.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
