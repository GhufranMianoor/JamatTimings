import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final DateTime? lastSynced;

  const OfflineBanner({super.key, this.lastSynced});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final timeStr = lastSynced != null
        ? '${lastSynced!.hour.toString().padLeft(2, '0')}:${lastSynced!.minute.toString().padLeft(2, '0')}'
        : 'Never';

    return Container(
      width: double.infinity,
      color: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 16, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Text(
            'Offline — showing data last synced: $timeStr',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
