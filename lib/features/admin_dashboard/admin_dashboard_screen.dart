import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/data/mock_data.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Badshahi Masjid as assigned masjid
    final assignedMasjid = MockData.masjids[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontFamily: 'Amiri')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out?'),
                  content: const Text('Are you sure you want to end your administration session?'),
                  actions: [
                    TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
                    TextButton(
                      child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        context.go('/home');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Assigned Masjids',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 12),
            
            // Masjid management card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          assignedMasjid.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Active'.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignedMasjid.address,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Timings are up to date',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Update Timings'),
                          onPressed: () => context.push('/admin/timings/${assignedMasjid.id}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            Card(
              color: AppTheme.primaryGreen.withOpacity(0.05),
              child: ListTile(
                leading: const Icon(Icons.add_business, color: AppTheme.primaryGreen),
                title: const Text('Register Another Masjid', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Submit a request to onboard a new masjid to this platform.'),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
                onTap: () => context.push('/admin/request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
