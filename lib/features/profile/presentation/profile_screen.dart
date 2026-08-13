import 'package:flutter/material.dart';
import '../../../shared/widgets/fade_through_route.dart';
import '../../achievements/presentation/achievements_screen.dart';

enum AttributeTrend { up, down, flat }

class Attribute {
  final String label;
  final IconData icon;
  final int score;
  final AttributeTrend trend;

  const Attribute({
    required this.label,
    required this.icon,
    required this.score,
    required this.trend,
  });
}

const _attributes = [
  Attribute(label: 'Wisdom', icon: Icons.psychology_outlined, score: 65, trend: AttributeTrend.up),
  Attribute(label: 'Strength', icon: Icons.fitness_center, score: 58, trend: AttributeTrend.up),
  Attribute(label: 'Discipline', icon: Icons.track_changes_outlined, score: 72, trend: AttributeTrend.up),
  Attribute(label: 'Balance', icon: Icons.favorite_outline, score: 44, trend: AttributeTrend.down),
  Attribute(label: 'Consistency', icon: Icons.local_fire_department_outlined, score: 60, trend: AttributeTrend.flat),
];

class CompletedQuest {
  final String title;
  final IconData icon;
  final int xp;
  final String whenLabel;

  const CompletedQuest({
    required this.title,
    required this.icon,
    required this.xp,
    required this.whenLabel,
  });
}

const _recentCompletions = [
  CompletedQuest(title: 'Morning workout', icon: Icons.fitness_center, xp: 50, whenLabel: 'Today'),
  CompletedQuest(title: '4 gym sessions this week', icon: Icons.fitness_center, xp: 150, whenLabel: 'Today'),
  CompletedQuest(title: 'Flutter deep work', icon: Icons.rocket_launch_outlined, xp: 80, whenLabel: 'Yesterday'),
  CompletedQuest(title: 'Read 20 pages', icon: Icons.menu_book_outlined, xp: 30, whenLabel: '2 days ago'),
  CompletedQuest(title: 'Evening walk', icon: Icons.self_improvement, xp: 20, whenLabel: '3 days ago'),
];

/// Level tier system — badge visually gets more "premium" at higher levels,
/// but stays within the app's single gold accent family. See LevelTier.forLevel().
class LevelTier {
  final String name;
  final Color color;
  final double borderWidth;
  final double glowOpacity;

  const LevelTier({
    required this.name,
    required this.color,
    required this.borderWidth,
    required this.glowOpacity,
  });

  static LevelTier forLevel(int level) {
    if (level < 6) {
      return const LevelTier(name: 'Novice', color: Color(0xFF8A8578), borderWidth: 1.5, glowOpacity: 0);
    } else if (level < 11) {
      return const LevelTier(name: 'Apprentice', color: Color(0xFFC9A45C), borderWidth: 1.5, glowOpacity: 0);
    } else if (level < 21) {
      return const LevelTier(name: 'Quester', color: Color(0xFFE8B84B), borderWidth: 2, glowOpacity: 0.15);
    } else if (level < 31) {
      return const LevelTier(name: 'Expert', color: Color(0xFFE8B84B), borderWidth: 2.5, glowOpacity: 0.25);
    } else {
      return const LevelTier(name: 'Legend', color: Color(0xFFF3D080), borderWidth: 3, glowOpacity: 0.35);
    }
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    const currentLevel = 12;
    final tier = LevelTier.forLevel(currentLevel);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            // Avatar + name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardColor,
                      border: Border.all(color: tier.color, width: tier.borderWidth),
                      boxShadow: tier.glowOpacity > 0
                          ? [BoxShadow(color: tier.color.withOpacity(tier.glowOpacity), blurRadius: 16, spreadRadius: 2)]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'K',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: tier.color),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Kunal Rathod', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('Joined 66 days ago', style: TextStyle(fontSize: 11, color: mutedColor)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Level card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(18)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tier.color.withOpacity(0.12),
                          border: Border.all(color: tier.color.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$currentLevel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: tier.color),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tier.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: SizedBox(
                              width: 90,
                              child: LinearProgressIndicator(
                                value: 0.49,
                                minHeight: 5,
                                backgroundColor: Colors.white.withOpacity(0.08),
                                color: tier.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text('2,450\n/ 5,000 XP', textAlign: TextAlign.right, style: TextStyle(fontSize: 9, color: mutedColor)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text('YOUR ATTRIBUTES', style: TextStyle(fontSize: 10, letterSpacing: 1, color: mutedColor)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: _attributes.asMap().entries.map((entry) {
                  final isLast = entry.key == _attributes.length - 1;
                  return _AttributeRow(attribute: entry.value, showDivider: !isLast, mutedColor: mutedColor);
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            Text('RECENT COMPLETIONS', style: TextStyle(fontSize: 10, letterSpacing: 1, color: mutedColor)),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: _recentCompletions.asMap().entries.map((entry) {
                  final isLast = entry.key == _recentCompletions.length - 1;
                  final quest = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                          child: Icon(quest.icon, size: 15, color: mutedColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(quest.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(quest.whenLabel, style: TextStyle(fontSize: 10, color: mutedColor)),
                            ],
                          ),
                        ),
                        Text('+${quest.xp} XP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: mutedColor)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).push(FadeThroughRoute(page: const AchievementsScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 18, color: mutedColor),
                        const SizedBox(width: 10),
                        const Text('Achievements', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Icon(Icons.chevron_right, size: 18, color: mutedColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  final Attribute attribute;
  final bool showDivider;
  final Color? mutedColor;

  const _AttributeRow({required this.attribute, required this.showDivider, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final trendIcon = switch (attribute.trend) {
      AttributeTrend.up => Icons.arrow_upward,
      AttributeTrend.down => Icons.arrow_downward,
      AttributeTrend.flat => Icons.remove,
    };
    final trendColor = switch (attribute.trend) {
      AttributeTrend.up => const Color(0xFF7FBF7F),
      AttributeTrend.down => const Color(0xFFC97F7F),
      AttributeTrend.flat => mutedColor,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(attribute.icon, size: 16, color: mutedColor),
              const SizedBox(width: 8),
              Text(attribute.label, style: const TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Text('${attribute.score}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Icon(trendIcon, size: 12, color: trendColor),
            ],
          ),
        ],
      ),
    );
  }
}