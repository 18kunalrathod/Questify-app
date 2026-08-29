import 'package:flutter/material.dart';
import '../../../shared/widgets/fade_through_route.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import '../../../shared/widgets/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../achievements/presentation/achievements_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/quest_provider.dart';
import '../../../core/utils/leveling.dart';

enum AttributeTrend { up, down, flat }

class Attribute {
  final String label;
  final AppIcon icon;
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
  Attribute(label: 'Wisdom', icon: AppIcon.document, score: 65, trend: AttributeTrend.up),
  Attribute(label: 'Strength', icon: AppIcon.streak, score: 58, trend: AttributeTrend.up),
  Attribute(label: 'Discipline', icon: AppIcon.focus, score: 72, trend: AttributeTrend.up),
  Attribute(label: 'Balance', icon: AppIcon.checklist, score: 44, trend: AttributeTrend.down),
  Attribute(label: 'Consistency', icon: AppIcon.quest, score: 60, trend: AttributeTrend.flat),
];

class CompletedQuest {
  final String title;
  final AppIcon icon;
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
  CompletedQuest(title: 'Morning workout', icon: AppIcon.streak, xp: 50, whenLabel: 'Today'),
  CompletedQuest(title: '4 gym sessions this week', icon: AppIcon.streak, xp: 150, whenLabel: 'Today'),
  CompletedQuest(title: 'Flutter deep work', icon: AppIcon.quest, xp: 80, whenLabel: 'Yesterday'),
  CompletedQuest(title: 'Read 20 pages', icon: AppIcon.document, xp: 30, whenLabel: '2 days ago'),
  CompletedQuest(title: 'Evening walk', icon: AppIcon.checklist, xp: 20, whenLabel: '3 days ago'),
];

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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final liveXp = ref.watch(questProvider).where((q) => q.completed).fold<int>(0, (sum, q) => sum + q.xp);
final totalXp = Leveling.totalXp(liveXp);
final currentLevel = Leveling.levelForXp(totalXp);
final xpIntoLevel = Leveling.xpIntoCurrentLevel(totalXp);
final tier = LevelTier.forLevel(currentLevel);

    return Scaffold(
      body: AmbientGlowBackground(
        strong: true,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(FadeThroughRoute(page: const SettingsScreen())),
                  icon: Icon(Icons.settings_outlined, color: mutedColor, size: 22),
                ),
              ),

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
                      child: Text('K', style: AppTextStyles.headline(context, size: 24).copyWith(color: tier.color)),
                    ),
                    const SizedBox(height: 12),
                    AppTextStyles.nameHighlight(context, name: 'Kunal Rathod', size: 18),
                    const SizedBox(height: 3),
                    Text('Joined 66 days ago', style: TextStyle(fontSize: 11, color: mutedColor)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: tier.color.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(18),
                  color: cardColor?.withOpacity(0.4),
                ),
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
                          child: Text('$currentLevel', style: AppTextStyles.stat(context, size: 16, color: tier.color)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tier.name, style: AppTextStyles.headline(context, size: 15)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: SizedBox(
                                width: 90,
                                child: LinearProgressIndicator(value: xpIntoLevel / Leveling.xpForNextLevel, minHeight: 4, backgroundColor: Colors.white.withOpacity(0.08), color: tier.color),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text('$xpIntoLevel\n/ ${Leveling.xpForNextLevel} XP', textAlign: TextAlign.right, style: TextStyle(fontSize: 9, color: mutedColor)),
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
                      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                            child: Center(child: AppIconWidget(icon: quest.icon, size: 14, color: mutedColor!)),
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
                          Text('+${quest.xp} XP', style: AppTextStyles.stat(context, size: 11, color: mutedColor)),
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
                          Text('Achievements', style: AppTextStyles.headline(context, size: 13)),
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
      decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))) : null),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppIconWidget(icon: attribute.icon, size: 15, color: mutedColor!),
              const SizedBox(width: 8),
              Text(attribute.label, style: const TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            children: [
              Text('${attribute.score}', style: AppTextStyles.stat(context, size: 13)),
              const SizedBox(width: 4),
              Icon(trendIcon, size: 12, color: trendColor),
            ],
          ),
        ],
      ),
    );
  }
}