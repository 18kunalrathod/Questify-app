import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quest.dart';

// The "notebook keeper" — holds the real quest list and defines the
// only ways it's allowed to change (toggle completion, add a quest, etc.)
class QuestNotifier extends StateNotifier<List<Quest>> {
  QuestNotifier() : super(_initialQuests);

  static const _initialQuests = [
    // ---------- DAILY ----------
    Quest(id: 'd1', title: 'Morning workout', xp: 50, category: QuestCategory.fitness, period: QuestPeriod.daily, completed: true),
    Quest(id: 'd2', title: 'Read 20 pages', xp: 30, category: QuestCategory.knowledge, period: QuestPeriod.daily),
    Quest(id: 'd3', title: 'Flutter deep work', xp: 80, category: QuestCategory.focus, period: QuestPeriod.daily),
    Quest(id: 'd4', title: 'Evening walk', xp: 20, category: QuestCategory.personal, period: QuestPeriod.daily),

    // ---------- WEEKLY ----------
    Quest(
      id: 'w1',
      title: 'Finish portfolio homepage',
      description: 'Design and build the landing page.',
      xp: 200,
      category: QuestCategory.focus,
      rarity: QuestRarity.epic,
      period: QuestPeriod.weekly,
      progress: 0.55,
      dueLabel: 'Due in 4 days',
    ),
    Quest(
      id: 'w2',
      title: '4 gym sessions this week',
      xp: 150,
      category: QuestCategory.fitness,
      period: QuestPeriod.weekly,
      progress: 1.0,
      completed: true,
      dueLabel: 'Completed',
    ),

    // ---------- MONTHLY ----------
    Quest(
      id: 'm1',
      title: 'Ship Questify v1',
      description: 'Complete the core features and ship your v1.0',
      xp: 500,
      category: QuestCategory.focus,
      rarity: QuestRarity.epic,
      period: QuestPeriod.monthly,
      progress: 0.80,
      dueLabel: 'Due in 10 days',
    ),
    Quest(
      id: 'm2',
      title: 'Run a 5K',
      description: 'Build endurance and crush your 5K run.',
      xp: 300,
      category: QuestCategory.fitness,
      period: QuestPeriod.monthly,
      progress: 0.60,
      dueLabel: 'Due in 7 days',
    ),
  ];

  // Toggle a specific quest's completion by its id.
  void toggleComplete(String questId) {
    state = [
      for (final quest in state)
        if (quest.id == questId) quest.copyWith(completed: !quest.completed) else quest,
    ];
  }

  List<Quest> forPeriod(QuestPeriod period) {
    return state.where((q) => q.period == period).toList();
  }
}

// The actual provider — this is what screens import and watch.
final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  return QuestNotifier();
});