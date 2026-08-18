import 'package:flutter/material.dart';
import '../../tools/presentation/tools_hub_screen.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../../shared/widgets/ambient_glow_background.dart';

class _Quest {
  final String title;
  final int xp;
  final bool completed;
  final IconData icon;

  const _Quest({
    required this.title,
    required this.xp,
    required this.icon,
    this.completed = false,
  });
}

const _quests = [
  _Quest(title: 'Morning workout', xp: 50, icon: Icons.fitness_center, completed: true),
  _Quest(title: 'Read 20 pages', xp: 30, icon: Icons.menu_book_outlined),
  _Quest(title: 'Flutter deep work', xp: 80, icon: Icons.code),
];

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final completedCount = _quests.where((q) => q.completed).length;

    return Scaffold(
      body: AmbientGlowBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tuesday, Aug 12', style: TextStyle(color: mutedColor, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        'Good evening, Kunal',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ToolsHubScreen())),
                    icon: Icon(Icons.grid_view_rounded, color: accent, size: 20),
                    style: IconButton.styleFrom(backgroundColor: cardColor),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TODAY\'S PROGRESS', style: TextStyle(color: mutedColor, fontSize: 10, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$completedCount',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                        ),
                        Text(' of ${_quests.length} quests', style: TextStyle(color: mutedColor, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: completedCount / _quests.length,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.06),
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Streak + focus time
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'day streak', value: '12', cardColor: cardColor)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: 'focus time', value: '2.5h', cardColor: cardColor)),
                ],
              ),

              const SizedBox(height: 12),

              // Analytics preview
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('WEEKLY OVERVIEW', style: TextStyle(color: mutedColor, fontSize: 10, letterSpacing: 0.5)),
                          Text('See all ›', style: TextStyle(color: accent, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [0.35, 0.6, 0.45, 1.0, 0.55, 0.3, 0.15].map((barHeight) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 40 * barHeight,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.3 + (barHeight * 0.5)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Calendar + Vault previews, side by side
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CalendarScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 16, color: accent),
                            const SizedBox(height: 10),
                            const Text('3 events today', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotesScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.menu_book_outlined, size: 16, color: accent),
                            const SizedBox(height: 10),
                            const Text('12 notes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text('TODAY\'S QUESTS', style: TextStyle(color: mutedColor, fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 10),

              ..._quests.map((quest) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _QuestTile(quest: quest, cardColor: cardColor, accent: accent, mutedColor: mutedColor),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? cardColor;

  const _StatCard({required this.label, required this.value, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: mutedColor, fontSize: 10)),
        ],
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  final _Quest quest;
  final Color? cardColor;
  final Color accent;
  final Color? mutedColor;

  const _QuestTile({
    required this.quest,
    required this.cardColor,
    required this.accent,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(quest.icon, size: 18, color: quest.completed ? mutedColor : accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quest.title,
              style: TextStyle(
                fontSize: 13,
                decoration: quest.completed ? TextDecoration.lineThrough : null,
                color: quest.completed ? mutedColor : null,
              ),
            ),
          ),
          Text('+${quest.xp} XP', style: TextStyle(color: quest.completed ? accent : mutedColor, fontSize: 11)),
        ],
      ),
    );
  }
}