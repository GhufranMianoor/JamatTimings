import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/widgets/islamic_pattern_bg.dart';
import 'package:jamat_timings/widgets/masjid_card.dart';
import 'package:jamat_timings/widgets/countdown_timer.dart';
import 'package:jamat_timings/widgets/offline_banner.dart';
import 'package:jamat_timings/core/utils/connectivity_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoading = false;

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate API fetch delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Badshahi Masjid as default nearest for the hero card
    final badshahiMasjid = MockData.masjids[0];
    final targetTime = DateTime.now().add(const Duration(hours: 1, minutes: 23));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jamat Timings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 24,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: IslamicPatternBackground(
        child: Column(
          children: [
            // If offline, display the offline status banner
            if (!isOnline) const OfflineBanner(),
            
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Top Hero Jamat Countdown Card
                    Card(
                      elevation: 4,
                      color: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        badshahiMasjid.name,
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nearest Masjid • ${badshahiMasjid.area}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onPrimary.withValues(alpha: 0.82),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.mosque,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: colorScheme.onPrimary.withValues(alpha: 0.14), height: 24),
                            
                            // Countdown timer
                            CountdownTimer(
                              targetTime: targetTime,
                              prayerName: 'isha',
                            ),
                            
                            const SizedBox(height: 8),
                            Text(
                              'Isha Jamat time: 20:45',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Approved Masjids Nearby',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${MockData.masjids.length} found',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // List of Masjid Cards
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ...MockData.masjids.map((masjid) {
                        // badshahi has next prayer mock
                        final hasNext = masjid.id == 'm1';
                        return MasjidCard(
                          masjid: masjid,
                          isFavourite: masjid.id == 'm1',
                          onFavouriteToggle: () {},
                          nextPrayerName: hasNext ? 'isha' : 'maghrib',
                          nextPrayerTime: hasNext ? '20:45' : '19:15',
                          isOffline: !isOnline,
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/map'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.map),
        label: const Text('Map View'),
      ),
    );
  }
}
