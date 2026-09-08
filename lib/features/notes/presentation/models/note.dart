import 'package:flutter/foundation.dart';
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

@immutable
class Note {
  final String id;
  final String title;
  final NoteCategory category;
  final quill.Document content;
  final DateTime updatedAt;
  final List<String> attachedFilePaths;

  const Note({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.updatedAt,
    this.attachedFilePaths = const [],
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      category: NoteCategory.values.byName(json['category'] as String),
      content: quill.Document.fromJson(
        List<dynamic>.from(json['content'] as List),
      ),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'category': category.name,
      'content': content.toDelta().toJson(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'category': category.name,
      'content': content.toDelta().toJson(),
    };
  }

  String get preview {
    final plainText = content.toPlainText().trim();
    return plainText.length > 60
        ? '${plainText.substring(0, 60)}...'
        : plainText;
  }
}