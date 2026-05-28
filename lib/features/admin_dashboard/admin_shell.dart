import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/app/theme.dart';

class AdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({
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
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.primaryGreen),
            label: 'My Masjids',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: AppTheme.primaryGreen),
            label: 'Register Masjid',
          ),
        ],
      ),
    );
  }
}
