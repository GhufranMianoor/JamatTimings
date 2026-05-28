import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final DateTime? lastSynced;

  const OfflineBanner({super.key, this.lastSynced});

  @override
  Widget build(BuildContext context) {
    final timeStr = lastSynced != null
        ? '${lastSynced!.hour.toString().padLeft(2, '0')}:${lastSynced!.minute.toString().padLeft(2, '0')}'
        : 'Never';

    return Container(
      width: double.infinity,
      color: Colors.amber.shade700,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Offline — showing data last synced: $timeStr',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
