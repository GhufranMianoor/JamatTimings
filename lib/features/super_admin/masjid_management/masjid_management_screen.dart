import 'package:flutter/material.dart';
import 'package:jamat_timings/data/mock_data.dart';
import 'package:jamat_timings/data/models/masjid.dart';

class MasjidManagementScreen extends StatefulWidget {
  const MasjidManagementScreen({super.key});

  @override
  State<MasjidManagementScreen> createState() => _MasjidManagementScreenState();
}

class _MasjidManagementScreenState extends State<MasjidManagementScreen> {
  List<Masjid> _masjids = [];

  @override
  void initState() {
    super.initState();
    _masjids = List.from(MockData.masjids);
  }

  void _toggleSuspension(Masjid masjid) {
    final bool isSuspended = masjid.status == 'suspended';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuspended ? 'Unsuspend Masjid?' : 'Suspend Masjid?'),
        content: Text(
          isSuspended
              ? 'This will make "${masjid.name}" fully visible to guests again.'
              : 'This will temporarily hide "${masjid.name}" and its timings from all search lists.',
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: Text(
              isSuspended ? 'Activate' : 'Suspend',
              style: TextStyle(
                color: isSuspended ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
              ),
            ),
            onPressed: () {
              setState(() {
                final index = _masjids.indexWhere((m) => m.id == masjid.id);
                if (index != -1) {
                  _masjids[index] = masjid.copyWith(
                    status: isSuspended ? 'active' : 'suspended',
                  );
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSuspended ? '${masjid.name} has been activated.' : '${masjid.name} has been suspended.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Masjid Listings', style: theme.textTheme.titleLarge),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _masjids.length,
        itemBuilder: (context, index) {
          final masjid = _masjids[index];
          final bool isSuspended = masjid.status == 'suspended';

          return Card(
            child: ListTile(
              leading: Icon(Icons.mosque, color: isSuspended ? colorScheme.onSurfaceVariant : colorScheme.primary),
              title: Text(masjid.name, style: theme.textTheme.titleMedium),
              subtitle: Text('${masjid.area ?? "Main"}, ${masjid.city}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSuspended ? colorScheme.secondary.withValues(alpha: 0.25) : colorScheme.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      masjid.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSuspended ? colorScheme.onSecondary : colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isSuspended ? Icons.play_arrow : Icons.pause,
                      color: isSuspended ? colorScheme.primary : colorScheme.secondary,
                    ),
                    onPressed: () => _toggleSuspension(masjid),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
