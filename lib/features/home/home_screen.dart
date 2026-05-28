import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/app/theme.dart';
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

    // Badshahi Masjid as default nearest for the hero card
    final BadshahiMasjid = MockData.masjids[0];
    final targetTime = DateTime.now().add(const Duration(hours: 1, minutes: 23));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jamat Timings',
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 24),
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
                      color: AppTheme.primaryGreen,
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
                                        BadshahiMasjid.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Nearest Masjid • ${BadshahiMasjid.area}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.mosque,
                                    color: AppTheme.accentGold,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            
                            // Countdown timer
                            CountdownTimer(
                              targetTime: targetTime,
                              prayerName: 'isha',
                            ),
                            
                            const SizedBox(height: 8),
                            Text(
                              'Isha Jamat time: 20:45',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
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
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        Text(
                          '${MockData.masjids.length} found',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                      }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/map'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.map),
        label: const Text('Map View'),
      ),
    );
  }
}
