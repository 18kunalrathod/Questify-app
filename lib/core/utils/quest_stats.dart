import '../models/quest.dart';

class QuestStats {
  /// Walks backward from today counting consecutive days with at least one
  /// completed quest. Today itself is only required if it already has a
  /// completion — otherwise counting starts from yesterday, so an
  /// in-progress day doesn't reset the streak early.
  static int currentStreak(List<Quest> quests) {
    final completedDays = quests
        .where((q) => q.completed && q.completedAt != null)
        .map((q) => DateTime(q.completedAt!.year, q.completedAt!.month, q.completedAt!.day))
        .toSet();

    if (completedDays.isEmpty) return 0;

    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);

    if (!completedDays.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (completedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// XP earned from completed quests since the start of the current
  /// calendar week (Monday).
  static int xpThisWeek(List<Quest> quests) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    return quests
        .where((q) => q.completed && q.completedAt != null && !q.completedAt!.isBefore(startOfWeek))
        .fold<int>(0, (sum, q) => sum + q.xp);
  }

  /// Normalized (0.0–1.0) XP totals for each day of the current week,
  /// Monday through Sunday, for a simple bar-chart visualization.
  static List<double> weeklyXpBars(List<Quest> quests) {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final dayTotals = List<int>.filled(7, 0);
    for (final quest in quests) {
      final completedAt = quest.completedAt;
      if (completedAt == null || !quest.completed) continue;
      final dayIndex = DateTime(completedAt.year, completedAt.month, completedAt.day)
          .difference(startOfWeek)
          .inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dayTotals[dayIndex] += quest.xp;
      }
    }

    final maxTotal = dayTotals.every((v) => v == 0) ? 1 : dayTotals.reduce((a, b) => a > b ? a : b);
    return dayTotals.map((v) => v / maxTotal).toList();
  }
}