import 'package:flutter/material.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/data/mock_data.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admins = MockData.admins;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Management', style: TextStyle(fontFamily: 'Amiri')),
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
                color: isSuper ? Colors.blue : AppTheme.primaryGreen,
                size: 32,
              ),
              title: Text(admin.fullName ?? 'Unnamed Admin', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(admin.email),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuper ? Colors.blue.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  admin.role.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSuper ? Colors.blue.shade800 : Colors.green.shade800,
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
