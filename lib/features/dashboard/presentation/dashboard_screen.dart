import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../tools/presentation/tools_hub_screen.dart';
import '../../calendar/presentation/calendar_screen.dart';
import '../../calendar/presentation/calendar_provider.dart';
import '../../notes/presentation/note_provider.dart';
import '../../analytics/presentation/analytics_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/quest.dart';
import '../../../core/providers/quest_provider.dart';
import '../../../core/utils/quest_stats.dart';
import '../../../core/utils/user_display.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import '../../../shared/widgets/app_icons.dart';
import '../../ledger/presentation/ledger_screen.dart';

const _weekdayNames = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
const _monthAbbr = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

String _todayLabel() {
  final now = DateTime.now();
  return '${_weekdayNames[now.weekday - 1]}, ${_monthAbbr[now.month - 1]} ${now.day}';
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;

    final user = Supabase.instance.client.auth.currentUser;
    final greetingName = displayNameFromEmail(user?.email);

    final allQuests = ref.watch(questProvider);
    final dayStart = QuestNotifier.currentQuestDayStart();
    final todaysQuests = allQuests
        .where((q) => q.period == QuestPeriod.daily && q.createdAt != null && !q.createdAt!.isBefore(dayStart))
        .toList();
    final completedCount = todaysQuests.where((q) => q.completed).length;
    final upNextQuest = todaysQuests.where((q) => !q.completed).isEmpty
        ? null
        : todaysQuests.firstWhere((q) => !q.completed);

    final streak = QuestStats.currentStreak(allQuests);
    final xpThisWeek = QuestStats.xpThisWeek(allQuests);
    final weeklyBars = QuestStats.weeklyXpBars(allQuests);

    final events = ref.watch(calendarProvider);
    final now = DateTime.now();
    final todayEventCount = events
        .where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day)
        .length;

    final notes = ref.watch(noteProvider);

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
                  Text(_todayLabel(), style: TextStyle(color: mutedColor, fontSize: 10, letterSpacing: 1)),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ToolsHubScreen())),
                    icon: Icon(Icons.grid_view_rounded, color: accent, size: 20),
                    style: IconButton.styleFrom(backgroundColor: cardColor),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hero: greeting in Playfair, then the bordered stat block
              AppTextStyles.nameHighlight(context, prefix: greetingPrefix(), name: greetingName, size: 15, weight: FontWeight.w600, baseColor: mutedColor),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(20),
                  color: cardColor?.withValues(alpha: 0.4),
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
                        Text('of ${todaysQuests.length} quests today', style: TextStyle(color: mutedColor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: todaysQuests.isEmpty ? 0.0 : completedCount / todaysQuests.length,
                          minHeight: 3,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
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
                      value: '$streak',
                      label: streak == 1 ? 'day streak' : 'day streak',
                      cardColor: cardColor,
                      accent: accent,
                      mutedColor: mutedColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      icon: AppIcon.quest,
                      value: '$xpThisWeek',
                      label: 'XP this week',
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
                          children: weeklyBars.map((barHeight) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 44 * barHeight,
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.25 + (barHeight * 0.5)),
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
                            Text(
                              todayEventCount == 0 ? 'No events today' : '$todayEventCount ${todayEventCount == 1 ? 'event' : 'events'} today',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LedgerScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppIconWidget(icon: AppIcon.checklist, size: 16, color: accent),
                            const SizedBox(height: 10),
                            Text(
                              notes.isEmpty ? 'No notes yet' : '${notes.length} ${notes.length == 1 ? 'note' : 'notes'}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Card-less "Up Next" row
              if (upNextQuest != null) ...[
                Text('UP NEXT', style: TextStyle(color: mutedColor, fontSize: 9, letterSpacing: 1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AppIconWidget(icon: upNextQuest.category.icon, size: 18, color: accent),
                    const SizedBox(width: 12),
                    Expanded(child: Text(upNextQuest.title, style: const TextStyle(fontSize: 13))),
                    Text('+${upNextQuest.xp}', style: AppTextStyles.stat(context, size: 12, color: accent)),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              Text('ALL QUESTS TODAY', style: TextStyle(color: mutedColor, fontSize: 9, letterSpacing: 1)),
              const SizedBox(height: 10),
              if (todaysQuests.isEmpty)
                Text('No quests yet today.', style: TextStyle(color: mutedColor, fontSize: 12))
              else
                ...todaysQuests.map((quest) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            AppIconWidget(icon: quest.category.icon, size: 16, color: quest.completed ? mutedColor! : accent),
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