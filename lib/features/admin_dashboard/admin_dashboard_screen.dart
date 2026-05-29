import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/data/mock_data.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Badshahi Masjid as assigned masjid
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final assignedMasjid = MockData.masjids[0];

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: theme.textTheme.titleLarge),
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
                      child: Text('Log Out', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
            Text(
              'My Assigned Masjids',
              style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary),
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
                          style: theme.textTheme.titleMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Active'.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignedMasjid.address,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: colorScheme.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Timings are up to date',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.primary),
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
              color: colorScheme.primary.withValues(alpha: 0.08),
              child: ListTile(
                leading: Icon(Icons.add_business, color: colorScheme.primary),
                title: const Text('Register Another Masjid', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Submit a request to onboard a new masjid to this platform.', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7))),
                trailing: Icon(Icons.chevron_right, color: colorScheme.primary),
                onTap: () => context.push('/admin/request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
