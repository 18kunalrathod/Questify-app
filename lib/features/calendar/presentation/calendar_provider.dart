import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'calendar_screen.dart' show CalendarEvent;

class CalendarNotifier extends StateNotifier<List<CalendarEvent>> {
  CalendarNotifier() : super([]) {
    loadEvents();
  }

  final _supabase = Supabase.instance.client;

  Future<void> loadEvents() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _supabase
        .from('calendar_events')
        .select()
        .eq('user_id', userId)
        .order('event_date');

    state = (response as List)
        .map((row) => CalendarEvent.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addEvent(CalendarEvent event) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final inserted = await _supabase
        .from('calendar_events')
        .insert(event.toInsertJson(userId))
        .select()
        .single();

    final newEvent = CalendarEvent.fromJson(inserted);
    state = [...state, newEvent];
  }

  Future<void> updateEvent(CalendarEvent event) async {
    await _supabase.from('calendar_events').update(event.toUpdateJson()).eq('id', event.id);

    state = [
      for (final existing in state)
        if (existing.id == event.id) event else existing,
    ];
  }

  Future<void> deleteEvent(String id) async {
    await _supabase.from('calendar_events').delete().eq('id', id);
    state = state.where((e) => e.id != id).toList();
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, List<CalendarEvent>>((ref) {
  return CalendarNotifier();
});