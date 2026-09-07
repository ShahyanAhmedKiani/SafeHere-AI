import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

/// Bottom-nav shell wrapping Home / Safety Map / Journey / Trusted Circle / Profile —
/// the five primary destinations, matching the original app's BottomNav.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _Tab('/', Icons.shield_outlined, Icons.shield, 'Home'),
    _Tab('/map', Icons.map_outlined, Icons.map, 'Map'),
    _Tab('/journey', Icons.route_outlined, Icons.route, 'Journey'),
    _Tab('/circle', Icons.people_outline, Icons.people, 'Circle'),
    _Tab('/profile', Icons.person_outline, Icons.person, 'Profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => t.path == location);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.rose.withOpacity(0.15),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon, color: AppColors.inkSoft),
                  selectedIcon: Icon(t.selectedIcon, color: AppColors.rose),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _Tab {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Tab(this.path, this.icon, this.selectedIcon, this.label);
}
