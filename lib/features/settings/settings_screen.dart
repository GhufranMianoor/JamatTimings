import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/core/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          // Theme settings
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark backgrounds'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            secondary: const Icon(Icons.dark_mode),
            activeColor: AppTheme.primaryGreen,
          ),
          
          // Data Management
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Local Cache Storage'),
            subtitle: const Text('Clear downloaded offline timings'),
            trailing: const Text('1.4 MB', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Offline Cache?'),
                  content: const Text(
                    'All offline saved timings will be removed. You will need internet connectivity to fetch them again.',
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Offline database cache cleared.')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Application About
          _buildSectionHeader('About App'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Jamat Timings App'),
            subtitle: Text('Find nearby mosques, track upcoming jama\'at times instantly, and save data offline.'),
            trailing: Text('v${AppConstants.appVersion}', style: TextStyle(color: Colors.grey)),
          ),
          
          const Divider(height: 40),
          
          // Admin Console entry point
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryGreen),
              label: const Text('Masjid Admin Dashboard Login', style: TextStyle(color: AppTheme.primaryGreen)),
              onPressed: () => context.push('/auth/login'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 24, bottom: 8),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGreen,
        letterSpacing: 0.5,
      ),
      child: Text(title.toUpperCase()),
    );
  }
}
