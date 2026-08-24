import 'package:flutter/material.dart';
import '../../tools/presentation/tools_hub_screen.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import '../../../shared/widgets/app_icons.dart';

class _Quest {
  final String title;
  final int xp;
  final bool completed;
  final AppIcon icon;

  const _Quest({
    required this.title,
    required this.xp,
    required this.icon,
    this.completed = false,
  });
}

const _quests = [
  _Quest(title: 'Morning workout', xp: 50, icon: AppIcon.quest, completed: true),
  _Quest(title: 'Read 20 pages', xp: 30, icon: AppIcon.document),
  _Quest(title: 'Flutter deep work', xp: 80, icon: AppIcon.quest),
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
        strong: true,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('TUESDAY, AUG 12', style: TextStyle(color: mutedColor, fontSize: 10, letterSpacing: 1)),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ToolsHubScreen())),
                    icon: Icon(Icons.grid_view_rounded, color: accent, size: 20),
                    style: IconButton.styleFrom(backgroundColor: cardColor),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hero: greeting in Playfair, then the bordered stat block
              AppTextStyles.nameHighlight(context, prefix: 'Good evening, ', name: 'Kunal', size: 15, weight: FontWeight.w600, baseColor: mutedColor),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: accent.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(20),
                  color: cardColor?.withOpacity(0.4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$completedCount', style: AppTextStyles.stat(context, size: 60, weight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Text('of ${_quests.length} quests today', style: TextStyle(color: mutedColor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: completedCount / _quests.length,
                          minHeight: 3,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tight paired stat cards, custom icons
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: AppIcon.streak,
                      value: '12',
                      label: 'day streak',
                      cardColor: cardColor,
                      accent: accent,
                      mutedColor: mutedColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      icon: AppIcon.focus,
                      value: '2.5h',
                      label: 'focus time',
                      cardColor: cardColor,
                      accent: accent,
                      mutedColor: mutedColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Full-width analytics card
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('WEEKLY OVERVIEW', style: TextStyle(color: mutedColor, fontSize: 9, letterSpacing: 0.5)),
                          Text('See all', style: TextStyle(color: accent, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [0.35, 0.6, 0.45, 1.0, 0.55, 0.3, 0.15].map((barHeight) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 44 * barHeight,
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.25 + (barHeight * 0.5)),
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

              const SizedBox(height: 12),

              // Calendar + Vault previews
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
                            AppIconWidget(icon: AppIcon.document, size: 16, color: accent),
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
                            AppIconWidget(icon: AppIcon.checklist, size: 16, color: accent),
                            const SizedBox(height: 10),
                            const Text('12 notes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Card-less "Up Next" row
              Text('UP NEXT', style: TextStyle(color: mutedColor, fontSize: 9, letterSpacing: 1)),
              const SizedBox(height: 12),
              ..._quests.where((q) => !q.completed).take(1).map((quest) => Row(
                    children: [
                      AppIconWidget(icon: quest.icon, size: 18, color: accent),
                      const SizedBox(width: 12),
                      Expanded(child: Text(quest.title, style: const TextStyle(fontSize: 13))),
                      Text('+${quest.xp}', style: AppTextStyles.stat(context, size: 12, color: accent)),
                    ],
                  )),

              const SizedBox(height: 24),
              Text('ALL QUESTS TODAY', style: TextStyle(color: mutedColor, fontSize: 9, letterSpacing: 1)),
              const SizedBox(height: 10),
              ..._quests.map((quest) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          AppIconWidget(icon: quest.icon, size: 16, color: quest.completed ? mutedColor! : accent),
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
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final AppIcon icon;
  final String value;
  final String label;
  final Color? cardColor;
  final Color accent;
  final Color? mutedColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.cardColor,
    required this.accent,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconWidget(icon: icon, size: 16, color: accent),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.stat(context, size: 18)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: mutedColor, fontSize: 10)),
        ],
      ),
    );
  }
}