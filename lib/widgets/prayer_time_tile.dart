import 'package:flutter/material.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/core/constants.dart';

class PrayerTimeTile extends StatelessWidget {
  final String prayerName;
  final List<String> jamatTimes;
  final bool isNext;

  const PrayerTimeTile({
    super.key,
    required this.prayerName,
    required this.jamatTimes,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final prayerColor = AppTheme.getPrayerColor(prayerName);
    final displayName = AppConstants.prayerDisplayNames[prayerName.toLowerCase()] ?? prayerName;
    final icon = AppConstants.prayerIcons[prayerName.toLowerCase()] ?? Icons.access_time;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isNext ? BorderSide(color: prayerColor, width: 2) : BorderSide.none,
      ),
      elevation: isNext ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Prayer Name/Icon Indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: prayerColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: prayerColor, size: 24),
            ),
            const SizedBox(width: 16),
            
            // Name label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isNext ? prayerColor : colorScheme.onSurface,
                    ),
                  ),
                  if (isNext)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: prayerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'UPCOMING',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Jamat Times Row
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: jamatTimes.isNotEmpty
                  ? jamatTimes.map((time) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          time,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isNext ? prayerColor : colorScheme.onSurface,
                          ),
                        ),
                      );
                    }).toList()
                  : [
                      const Text(
                        '--:--',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}
