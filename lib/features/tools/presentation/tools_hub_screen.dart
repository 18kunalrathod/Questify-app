import 'package:flutter/material.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';

class ToolItem {
  final String label;
  final IconData icon;
  final Widget destination;

  const ToolItem({required this.label, required this.icon, required this.destination});
}

class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;

    final tools = [
      ToolItem(label: 'Calendar', icon: Icons.calendar_today_outlined, destination: const CalendarScreen()),
      ToolItem(label: 'Notes & Vault', icon: Icons.menu_book_outlined, destination: const NotesScreen()),
      ToolItem(label: 'Analytics', icon: Icons.bar_chart_outlined, destination: const AnalyticsScreen()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: tools.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final tool = tools[index];
            return GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => tool.destination)),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
                      child: Icon(tool.icon, size: 17, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(tool.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                    Icon(Icons.chevron_right, size: 16, color: mutedColor),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}