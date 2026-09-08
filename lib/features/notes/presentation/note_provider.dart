import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/note.dart';

class NoteNotifier extends StateNotifier<List<Note>> {
  NoteNotifier() : super(const []) {
    loadNotes();
  }

  final SupabaseClient _client = Supabase.instance.client;

  Future<void> loadNotes() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      state = [];
      return;
    }

    final response = await _client
        .from('notes')
        .select()
        .order('updated_at', ascending: false);

    final rows = response as List<dynamic>;

    state = rows
        .map(
          (row) => Note.fromJson(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  Future<Note> saveNote(Note note) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to save a note.');
    }

    final savedRow = note.id.isEmpty
        ? await _client
            .from('notes')
            .insert(note.toInsertJson(user.id))
            .select()
            .single()
        : await _client
            .from('notes')
            .update(note.toUpdateJson())
            .eq('id', note.id)
            .select()
            .single();

    final savedNote = Note.fromJson(
      Map<String, dynamic>.from(savedRow),
    );

    state = note.id.isEmpty
        ? [savedNote, ...state]
        : [
            for (final item in state)
              if (item.id == savedNote.id) savedNote else item,
          ];

    return savedNote;
  }

  Future<void> deleteNote(String noteId) async {
    await _client.from('notes').delete().eq('id', noteId);

    state = state.where((note) => note.id != noteId).toList();
  }
}

final noteProvider = StateNotifierProvider<NoteNotifier, List<Note>>((ref) {
  return NoteNotifier();
});