import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/focus_log.dart';

class FocusLogNotifier extends StateNotifier<List<FocusLog>> {
  FocusLogNotifier() : super(const []) {
    loadLogs();
  }

  final SupabaseClient _client = Supabase.instance.client;

  List<FocusLog> _sorted(List<FocusLog> logs) {
    final copy = [...logs];
    copy.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return copy;
  }

  Future<void> loadLogs() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      state = [];
      return;
    }

    final response = await _client
        .from('focus_logs')
        .select()
        .order('logged_at', ascending: false);

    state = (response as List<dynamic>)
        .map((row) => FocusLog.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<void> addLog({
    required String note,
    int? minutes,
    String? questTitle,
    DateTime? loggedAt,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to save a log.');
    }

    final draft = FocusLog(
      id: '',
      note: note,
      minutes: minutes,
      questTitle: questTitle,
      loggedAt: loggedAt ?? DateTime.now(),
    );

    final row = await _client
        .from('focus_logs')
        .insert(draft.toInsertJson(user.id))
        .select()
        .single();

    final saved = FocusLog.fromJson(Map<String, dynamic>.from(row));
    state = _sorted([...state, saved]);
  }

  Future<void> updateLog(FocusLog log) async {
    final row = await _client
        .from('focus_logs')
        .update(log.toUpdateJson())
        .eq('id', log.id)
        .select()
        .single();

    final saved = FocusLog.fromJson(Map<String, dynamic>.from(row));
    state = _sorted([
      for (final item in state)
        if (item.id == saved.id) saved else item,
    ]);
  }

  Future<void> deleteLog(String id) async {
    await _client.from('focus_logs').delete().eq('id', id);
    state = state.where((log) => log.id != id).toList();
  }
}

final focusLogProvider = StateNotifierProvider<FocusLogNotifier, List<FocusLog>>((ref) {
  return FocusLogNotifier();
});