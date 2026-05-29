import 'package:flutter/material.dart';
import 'package:jamat_timings/data/mock_data.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final admins = MockData.admins;

    return Scaffold(
      appBar: AppBar(
        title: Text('Administrator Management', style: theme.textTheme.titleLarge),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: admins.length,
        itemBuilder: (context, index) {
          final admin = admins[index];
          final bool isSuper = admin.isSuperAdmin;

          return Card(
            child: ListTile(
              leading: Icon(
                isSuper ? Icons.supervised_user_circle : Icons.person,
                color: isSuper ? colorScheme.secondary : colorScheme.primary,
                size: 32,
              ),
              title: Text(admin.fullName ?? 'Unnamed Admin', style: theme.textTheme.titleMedium),
              subtitle: Text(admin.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuper ? colorScheme.secondary.withValues(alpha: 0.22) : colorScheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  admin.role.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSuper ? colorScheme.onSecondary : colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
