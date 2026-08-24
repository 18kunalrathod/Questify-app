import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import '../../../shared/widgets/app_icons.dart';

enum AchievementTier { common, rare, epic }

extension AchievementTierX on AchievementTier {
  double get borderWidth => switch (this) {
        AchievementTier.common => 1.5,
        AchievementTier.rare => 2,
        AchievementTier.epic => 2,
      };

  double get glowOpacity => switch (this) {
        AchievementTier.common => 0,
        AchievementTier.rare => 0.12,
        AchievementTier.epic => 0.18,
      };

  double get size => switch (this) {
        AchievementTier.common => 56,
        AchievementTier.rare => 56,
        AchievementTier.epic => 60,
      };
}

class Achievement {
  final String title;
  final AppIcon icon;
  final AchievementTier tier;
  final bool unlocked;
  final String unlockHint;

  const Achievement({
    required this.title,
    required this.icon,
    required this.tier,
    required this.unlockHint,
    this.unlocked = false,
  });
}

const _achievements = [
  Achievement(title: 'First Step', icon: AppIcon.quest, tier: AchievementTier.common, unlocked: true, unlockHint: 'Complete your first quest'),
  Achievement(title: '7 Day Streak', icon: AppIcon.streak, tier: AchievementTier.common, unlocked: true, unlockHint: 'Maintain a 7-day streak'),
  Achievement(title: 'Deep Focus', icon: AppIcon.focus, tier: AchievementTier.rare, unlocked: true, unlockHint: 'Complete 5 focus sessions'),
  Achievement(title: '30 Day Streak', icon: AppIcon.streak, tier: AchievementTier.rare, unlockHint: 'Maintain a 30-day streak'),
  Achievement(title: 'Knowledge Seeker', icon: AppIcon.document, tier: AchievementTier.rare, unlockHint: 'Complete 10 Knowledge quests'),
  Achievement(title: 'Ship It', icon: AppIcon.quest, tier: AchievementTier.epic, unlocked: true, unlockHint: 'Ship a project or feature'),
  Achievement(title: 'Quest Master', icon: AppIcon.checklist, tier: AchievementTier.epic, unlockHint: 'Complete 50 quests'),
  Achievement(title: 'Legendary', icon: AppIcon.streak, tier: AchievementTier.epic, unlockHint: 'Reach the highest level'),
];

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final unlockedCount = _achievements.where((a) => a.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: Text('Achievements', style: AppTextStyles.headline(context, size: 18))),
      body: AmbientGlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$unlockedCount of ${_achievements.length} unlocked', style: TextStyle(color: mutedColor, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _achievements.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final achievement = _achievements[index];
                    return _AchievementBadge(
                      achievement: achievement,
                      accent: accent,
                      mutedColor: mutedColor,
                      onTap: () => _showUnlockHint(context, achievement),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
                  child: Text('Tap a badge to see how to unlock it', textAlign: TextAlign.center, style: TextStyle(color: mutedColor, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnlockHint(BuildContext context, Achievement achievement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(achievement.unlocked ? 'Unlocked: ${achievement.title}' : achievement.unlockHint),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final Color accent;
  final Color? mutedColor;
  final VoidCallback onTap;

  const _AchievementBadge({required this.achievement, required this.accent, required this.mutedColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = !achievement.unlocked;
    final tier = achievement.tier;
    final badgeColor = locked ? Colors.white.withOpacity(0.08) : accent;
    final size = locked ? 56.0 : tier.size;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: locked ? Theme.of(context).cardTheme.color : accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: badgeColor.withOpacity(locked ? 1 : 0.35 + (tier.glowOpacity)), width: locked ? 1.5 : tier.borderWidth),
              boxShadow: (!locked && tier.glowOpacity > 0) ? [BoxShadow(color: accent.withOpacity(tier.glowOpacity), blurRadius: 12, spreadRadius: 2)] : null,
            ),
            alignment: Alignment.center,
            child: locked
                ? Icon(Icons.lock_outline, size: 18, color: Colors.white.withOpacity(0.25))
                : AppIconWidget(icon: achievement.icon, size: 20, color: accent),
          ),
          const SizedBox(height: 6),
          Text(
            locked ? 'Locked' : achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 8, fontWeight: locked ? FontWeight.w500 : FontWeight.w700, color: locked ? Colors.white.withOpacity(0.25) : accent),
          ),
        ],
      ),
    );
  }
}