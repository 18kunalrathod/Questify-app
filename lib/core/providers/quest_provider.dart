import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quest.dart';

class QuestNotifier extends StateNotifier<List<Quest>> {
  QuestNotifier() : super(const []) {
    loadQuests();
  }

  final SupabaseClient _client = Supabase.instance.client;

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
  }

  Future<void> toggleComplete(String questId) async {
    final quest = state.firstWhere((item) => item.id == questId);

    final updatedRow = await _client
        .from('quests')
        .update({'completed': !quest.completed})
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

    final createdRow = await _client
        .from('quests')
        .insert({
          'user_id': user.id,
          'title': title,
          'xp': xp,
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

  List<Quest> forPeriod(QuestPeriod period) {
    return state.where((quest) => quest.period == period).toList();
  }
}

final questProvider = StateNotifierProvider<QuestNotifier, List<Quest>>((ref) {
  return QuestNotifier();
});