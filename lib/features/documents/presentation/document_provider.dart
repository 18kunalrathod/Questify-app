import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/document.dart';

class DocumentNotifier extends StateNotifier<List<Document>> {
  DocumentNotifier() : super([]) {
    loadDocuments();
  }

  final _client = Supabase.instance.client;

  Future<void> loadDocuments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _client
        .from('documents')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    state = (response as List)
        .map((json) => Document.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> uploadDocument({
    required String fileName,
    required String storagePath,
    required int fileSizeBytes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final tempDoc = Document(
      id: '',
      userId: userId,
      fileName: fileName,
      storagePath: storagePath,
      fileSizeBytes: fileSizeBytes,
      createdAt: DateTime.now(),
    );

    final response = await _client
        .from('documents')
        .insert(tempDoc.toInsertJson(userId))
        .select()
        .single();

    final savedDoc = Document.fromJson(response);
    state = [savedDoc, ...state];
  }

  Future<void> deleteDocument(String id) async {
    await _client.from('documents').delete().eq('id', id);
    state = state.where((doc) => doc.id != id).toList();
  }
}

final documentProvider =
    StateNotifierProvider<DocumentNotifier, List<Document>>((ref) {
  return DocumentNotifier();
});