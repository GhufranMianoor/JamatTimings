import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/app/theme.dart';

class GuestShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const GuestShell({
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
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque, color: AppTheme.primaryGreen),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppTheme.primaryGreen),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.search, color: AppTheme.primaryGreen),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star, color: AppTheme.primaryGreen),
            label: 'Favourites',
          ),
        ],
      ),
    );
  }
}
