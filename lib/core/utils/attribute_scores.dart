import 'dart:math';

import '../models/quest.dart';

class AttributeScores {
  final int wisdom;
  final int strength;
  final int discipline;
  final int balance;
  final int consistency;

  const AttributeScores({
    required this.wisdom,
    required this.strength,
    required this.discipline,
    required this.balance,
    required this.consistency,
  });

  static int _clamp(num value) => value.clamp(0, 100).round();

  factory AttributeScores.fromQuests(List<Quest> quests) {
    final completed = quests.where((q) => q.completed).toList();

    int countFor(QuestCategory category) =>
        completed.where((q) => q.category == category).length;

    final fitnessCount = countFor(QuestCategory.fitness);
    final focusCount = countFor(QuestCategory.focus);
    final knowledgeCount = countFor(QuestCategory.knowledge);
    final personalCount = countFor(QuestCategory.personal);

    final strength = _clamp(fitnessCount * 2);
    final discipline = _clamp(focusCount * 2);
    final wisdom = _clamp(knowledgeCount * 2);
    final consistency = _clamp(completed.length);

    // Balance rewards spread across categories; personal counts at half
    // weight since it doesn't map to a specific attribute on its own.
    final weighted = [
      fitnessCount.toDouble(),
      focusCount.toDouble(),
      knowledgeCount.toDouble(),
      personalCount * 0.5,
    ];
    final total = weighted.fold<double>(0, (a, b) => a + b);

    int balance;
    if (total == 0) {
      balance = 50; // neutral starting point with no data yet
    } else {
      final mean = total / weighted.length;
      final variance = weighted
              .map((c) => (c - mean) * (c - mean))
              .fold<double>(0, (a, b) => a + b) /
          weighted.length;
      final stdDev = sqrt(variance);
      final unevenness = mean == 0 ? 0.0 : (stdDev / mean);
      balance = _clamp(100 - (unevenness * 100));
    }

    return AttributeScores(
      wisdom: wisdom,
      strength: strength,
      discipline: discipline,
      balance: balance,
      consistency: consistency,
    );
  }
}