import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/app/theme.dart';

class SuperAdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const SuperAdminShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.rate_review_outlined),
            selectedIcon: Icon(Icons.rate_review, color: AppTheme.primaryGreen),
            label: 'Review Queue',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque, color: AppTheme.primaryGreen),
            label: 'Masjids',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppTheme.primaryGreen),
            label: 'Admins',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppTheme.primaryGreen),
            label: 'Audit Logs',
          ),
        ],
      ),
    );
  }
}
