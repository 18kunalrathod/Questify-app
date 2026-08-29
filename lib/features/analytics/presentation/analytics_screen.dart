import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/quest.dart';
import '../../../core/providers/quest_provider.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import '../../../shared/widgets/app_icons.dart';

enum AnalyticsRange { week, month }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsRange _range = AnalyticsRange.week;

  // Fake historical chart data — real day-by-day history needs persistence,
  // which comes in the backend phase. This bar shape mirrors Dashboard's preview.
  static const _weeklyBars = [0.35, 0.6, 0.45, 1.0, 0.55, 0.3, 0.15];
  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _highlightedDayIndex = 3;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;

    // These two ARE computed from real shared quest data.
    final allQuests = ref.watch(questProvider);
    final completedQuests = allQuests.where((q) => q.completed).toList();
    final totalXpEarned = completedQuests.fold<int>(0, (sum, q) => sum + q.xp);

    final categoryCounts = <QuestCategory, int>{};
    for (final quest in completedQuests) {
      categoryCounts[quest.category] = (categoryCounts[quest.category] ?? 0) + 1;
    }
    final maxCategoryCount = categoryCounts.values.isEmpty ? 1 : categoryCounts.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: Text('Analytics', style: AppTextStyles.headline(context, size: 18))),
      body: AmbientGlowBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: AnalyticsRange.values.map((range) {
                    final isActive = _range == range;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _range = range),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(color: isActive ? accent : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                          alignment: Alignment.center,
                          child: Text(
                            range == AnalyticsRange.week ? 'Week' : 'Month',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Theme.of(context).scaffoldBackgroundColor : mutedColor),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${completedQuests.length}', style: AppTextStyles.stat(context, size: 20)),
                          const SizedBox(height: 2),
                          Text('quests completed', style: TextStyle(color: mutedColor, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$totalXpEarned', style: AppTextStyles.stat(context, size: 20, color: accent)),
                          const SizedBox(height: 2),
                          Text('XP earned', style: TextStyle(color: mutedColor, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('XP THIS ${_range == AnalyticsRange.week ? 'WEEK' : 'MONTH'}', style: TextStyle(color: mutedColor, fontSize: 9, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _weeklyBars.map((barHeight) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 50 * barHeight,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.25 + (barHeight * 0.5)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _dayLabels.asMap().entries.map((entry) {
                        final isHighlighted = entry.key == _highlightedDayIndex;
                        return Text(entry.value, style: TextStyle(fontSize: 8, color: isHighlighted ? accent : mutedColor, fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400));
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text('BY CATEGORY', style: TextStyle(color: mutedColor, fontSize: 9, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              if (categoryCounts.isEmpty)
                Text('Complete a quest to see your breakdown.', style: TextStyle(color: mutedColor, fontSize: 12))
              else
                ...QuestCategory.values.where((c) => categoryCounts.containsKey(c)).map((category) {
                  final count = categoryCounts[category]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                AppIconWidget(icon: category.icon, size: 14, color: accent),
                                const SizedBox(width: 6),
                                Text(category.label, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            Text('$count', style: TextStyle(color: mutedColor, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: count / maxCategoryCount,
                            minHeight: 5,
                            backgroundColor: Colors.white.withOpacity(0.06),
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current streak', style: TextStyle(color: mutedColor, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('12 days', style: AppTextStyles.stat(context, size: 18)),
                      ],
                    ),
                    AppIconWidget(icon: AppIcon.streak, size: 24, color: accent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}