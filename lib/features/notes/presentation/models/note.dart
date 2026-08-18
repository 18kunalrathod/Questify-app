import 'package:flutter_quill/flutter_quill.dart' as quill;

enum NoteCategory { programming, gym, ideas, personal }

extension NoteCategoryX on NoteCategory {
  String get label => switch (this) {
        NoteCategory.programming => 'Programming',
        NoteCategory.gym => 'Gym',
        NoteCategory.ideas => 'Ideas',
        NoteCategory.personal => 'Personal',
      };
}

class Note {
  final String id;
  final String title;
  final NoteCategory category;
  final quill.Document content;
  final DateTime updatedAt;
  final List<String> attachedFilePaths;

  Note({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.updatedAt,
    this.attachedFilePaths = const [],
  });

  String get preview {
    final plainText = content.toPlainText().trim();
    return plainText.length > 60 ? '${plainText.substring(0, 60)}...' : plainText;
  }
}