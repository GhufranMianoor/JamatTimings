import 'package:flutter/material.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/data/models/masjid.dart';
import 'package:jamat_timings/core/utils/distance_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MasjidCard extends StatelessWidget {
  final Masjid masjid;
  final bool isFavourite;
  final VoidCallback? onFavouriteToggle;
  final String? nextPrayerName;
  final String? nextPrayerTime;
  final bool isOffline;

  const MasjidCard({
    super.key,
    required this.masjid,
    required this.isFavourite,
    this.onFavouriteToggle,
    this.nextPrayerName,
    this.nextPrayerTime,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surfaceVariant = colorScheme.surfaceContainerHighest;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/masjid/${masjid.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mosque Green Accent Strip
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Masjid Info Block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            masjid.name,
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOffline) ...[
                          const SizedBox(width: 4),
                          const Tooltip(
                            message: 'Cached offline data',
                            child: Icon(Icons.cloud_off_outlined, size: 14),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      masjid.area != null ? '${masjid.area}, ${masjid.city}' : masjid.city,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Next Jamat display
                    if (nextPrayerName != null && nextPrayerTime != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.getPrayerColor(nextPrayerName!).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_filled,
                              size: 14,
                              color: AppTheme.getPrayerColor(nextPrayerName!),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Next: ${nextPrayerName!.toUpperCase()} at $nextPrayerTime',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getPrayerColor(nextPrayerName!),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text(
                        'No timings scheduled today',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Action / Badge Block
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavourite ? Icons.star : Icons.star_border,
                      color: isFavourite ? colorScheme.secondary : colorScheme.outline,
                    ),
                    onPressed: onFavouriteToggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 24),
                  if (masjid.distanceKm != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceVariant.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        DistanceUtils.formatDistance(masjid.distanceKm!),
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }
}
