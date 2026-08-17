import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/quests/presentation/quest_board_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/focus/presentation/focus_screen.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _tabs = const [
    DashboardScreen(),
    QuestBoardScreen(),
    FocusScreen(),
    ProfileScreen(),
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



/// The recurring "signature" visual motif — a slowly rotating dashed ring.
/// Used behind hero stats, avatars, logos, and timers throughout the app
/// to create a consistent visual identity across every screen.
class OrbitRing extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const OrbitRing({
    super.key,
    this.size = 80,
    required this.color,
    this.duration = const Duration(seconds: 20),
  });

  @override
  State<OrbitRing> createState() => _OrbitRingState();
}

class _OrbitRingState extends State<OrbitRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159265,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: widget.color, width: 1, style: BorderStyle.solid),
        ),
      ),
    );
  }
}