import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/progress_photo.dart';

class ProgressPhotoNotifier extends StateNotifier<List<ProgressPhoto>> {
  ProgressPhotoNotifier() : super([]) {
    loadPhotos();
  }

  final _client = Supabase.instance.client;

  Future<void> loadPhotos() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _client
        .from('progress_photos')
        .select()
        .eq('user_id', userId)
        .order('taken_at', ascending: false);

    state = (response as List)
        .map((json) => ProgressPhoto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> uploadPhoto({
    required String storagePath,
    required int fileSizeBytes,
    DateTime? takenAt,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final tempPhoto = ProgressPhoto(
      id: '',
      userId: userId,
      storagePath: storagePath,
      fileSizeBytes: fileSizeBytes,
      takenAt: takenAt ?? DateTime.now(),
      createdAt: DateTime.now(),
    );

    final response = await _client
        .from('progress_photos')
        .insert(tempPhoto.toInsertJson(userId))
        .select()
        .single();

    final savedPhoto = ProgressPhoto.fromJson(response);
    state = [savedPhoto, ...state];
  }

  Future<void> deletePhoto(String id) async {
    await _client.from('progress_photos').delete().eq('id', id);
    state = state.where((photo) => photo.id != id).toList();
  }

  /// The earliest photo taken — the "Week 1" side of the comparison view.
  ProgressPhoto? get earliestPhoto {
    if (state.isEmpty) return null;
    return state.reduce((a, b) => a.takenAt.isBefore(b.takenAt) ? a : b);
  }

  /// The most recent photo — the "latest" side of the comparison view.
  ProgressPhoto? get latestPhoto {
    if (state.isEmpty) return null;
    return state.reduce((a, b) => a.takenAt.isAfter(b.takenAt) ? a : b);
  }
}

final progressPhotoProvider =
    StateNotifierProvider<ProgressPhotoNotifier, List<ProgressPhoto>>((ref) {
  return ProgressPhotoNotifier();
});