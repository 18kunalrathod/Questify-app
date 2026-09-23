import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quest.dart';
import '../data/daily_quest_templates.dart';

class QuestNotifier extends StateNotifier<List<Quest>> {
  QuestNotifier() : super(const []) {
    loadQuests();
  }

  final SupabaseClient _client = Supabase.instance.client;
  final Random _random = Random();

  static DateTime currentQuestDayStart() {
    final now = DateTime.now();
    final todayReset = DateTime(now.year, now.month, now.day, 5, 30);
    if (now.isBefore(todayReset)) {
      return todayReset.subtract(const Duration(days: 1));
    }
    return todayReset;
  }

  Future<void> loadQuests() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      state = [];
      return;
    }

    final response = await _client
        .from('quests')
        .select()
        .order('created_at');

    final rows = response as List<dynamic>;

    state = rows
        .map(
          (row) => Quest.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();

    await _ensureTodaysDailyChallenges(user.id);
  }

  Future<void> _ensureTodaysDailyChallenges(String userId) async {
    final dayStart = currentQuestDayStart();

    final alreadyGenerated = state.any(
      (q) => q.isDailyChallenge && q.createdAt != null && !q.createdAt!.isBefore(dayStart),
    );

    if (alreadyGenerated) return;

    final count = 3 + _random.nextInt(4); // 3 to 6 inclusive
    final shuffled = List<DailyQuestTemplate>.from(dailyQuestTemplates)..shuffle(_random);
    final chosen = shuffled.take(count).toList();

    final rowsToInsert = chosen
        .map((template) => {
              'user_id': userId,
              'title': template.title,
              'xp': template.xp,
              'category': template.category.name,
              'period': QuestPeriod.daily.name,
              'is_daily_challenge': true,
            })
        .toList();

    final insertedRows = await _client
        .from('quests')
        .insert(rowsToInsert)
        .select();

    final insertedQuests = (insertedRows as List<dynamic>)
        .map((row) => Quest.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();

    state = [...state, ...insertedQuests];
  }

  Future<void> toggleComplete(String questId) async {
    final quest = state.firstWhere((item) => item.id == questId);
    final newCompleted = !quest.completed;

    final updatedRow = await _client
        .from('quests')
        .update({
          'completed': newCompleted,
          'completed_at': newCompleted ? DateTime.now().toIso8601String() : null,
        })
        .eq('id', questId)
        .select()
        .single();

    final updatedQuest = Quest.fromJson(
      Map<String, dynamic>.from(updatedRow),
    );

    state = [
      for (final item in state)
        if (item.id == questId) updatedQuest else item,
    ];
  }

  Future<void> addQuest({
    required String title,
    required int xp,
    required QuestCategory category,
    required QuestPeriod period,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to create a quest.');
    }

    final cappedXp = xp > 50 ? 50 : xp;

    final createdRow = await _client
        .from('quests')
        .insert({
          'user_id': user.id,
          'title': title,
          'xp': cappedXp,
          'category': category.name,
          'period': period.name,
        })
        .select()
        .single();

    final createdQuest = Quest.fromJson(
      Map<String, dynamic>.from(createdRow),
    );

    state = [...state, createdQuest];
  }

  Future<void> deleteQuest(String questId) async {
    await _client.from('quests').delete().eq('id', questId);
    state = state.where((quest) => quest.id != questId).toList();
  }

  List<Quest> forPeriod(QuestPeriod period) {
    return state.where((quest) => quest.period == period).toList();
  }
}

final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  return QuestNotifier();
});