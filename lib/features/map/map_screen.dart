import 'package:flutter/material.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Masjid Map Explorer',
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Map Placeholder Mock UI
          Container(
            color: Colors.blueGrey.shade50,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: Colors.blueGrey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Interactive Google Map',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Shows nearby approved masjids on a live map coordinate layout. Requires Google Maps API Key setup.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              masjid.address,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Next Jamat: ISHA 20:45',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
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
    );
  }
}
