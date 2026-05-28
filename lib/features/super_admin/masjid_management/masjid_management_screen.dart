import 'package:flutter/material.dart';
import 'package:jamat_timings/app/theme.dart';
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
            child: Text(isSuspended ? 'Activate' : 'Suspend', style: TextStyle(color: isSuspended ? Colors.green : Colors.orange)),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Listings', style: TextStyle(fontFamily: 'Amiri')),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _masjids.length,
        itemBuilder: (context, index) {
          final masjid = _masjids[index];
          final bool isSuspended = masjid.status == 'suspended';

          return Card(
            child: ListTile(
              leading: Icon(Icons.mosque, color: isSuspended ? Colors.grey : AppTheme.primaryGreen),
              title: Text(masjid.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${masjid.area ?? "Main"}, ${masjid.city}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSuspended ? Colors.orange.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      masjid.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSuspended ? Colors.orange.shade800 : Colors.green.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isSuspended ? Icons.play_arrow : Icons.pause,
                      color: isSuspended ? Colors.green : Colors.orange,
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
