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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Theme settings
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark backgrounds'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
            secondary: const Icon(Icons.dark_mode),
            activeThumbColor: colorScheme.primary,
          ),

          // Data Management
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Local Cache Storage'),
            subtitle: const Text('Clear downloaded offline timings'),
            trailing: Text('1.4 MB', style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
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
                      child: Text('Clear', style: TextStyle(color: colorScheme.error)),
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
          _buildSectionHeader(context, 'About App'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Jamat Timings App'),
            subtitle: const Text('Find nearby mosques, track upcoming jama\'at times instantly, and save data offline.'),
            trailing: Text('v${AppConstants.appVersion}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),

          const Divider(height: 40),

          // Admin Console entry point
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Icon(Icons.admin_panel_settings, color: colorScheme.primary),
              label: Text('Masjid Admin Dashboard Login', style: TextStyle(color: colorScheme.primary)),
              onPressed: () => context.push('/auth/login'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
