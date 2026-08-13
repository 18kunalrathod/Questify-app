import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _tabs = const [
    DashboardScreen(),
    _PlaceholderTab(label: 'Quest Board'),
    _PlaceholderTab(label: 'Focus Mode'),
    _PlaceholderTab(label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      // IndexedStack keeps all four tabs alive in memory and just shows/hides
      // the active one — see explanation below for why this matters.
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Theme.of(context).cardTheme.color,
        indicatorColor: accent.withOpacity(0.15),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: mutedColor),
            selectedIcon: Icon(Icons.home_rounded, color: accent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined, color: mutedColor),
            selectedIcon: Icon(Icons.track_changes, color: accent),
            label: 'Quests',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined, color: mutedColor),
            selectedIcon: Icon(Icons.timer, color: accent),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: mutedColor),
            selectedIcon: Icon(Icons.person, color: accent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$label (coming soon)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}