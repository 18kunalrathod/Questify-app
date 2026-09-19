import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

enum NoteCategory { programming, gym, ideas, personal }

extension NoteCategoryX on NoteCategory {
  String get label => switch (this) {
        NoteCategory.programming => 'Programming',
        NoteCategory.gym => 'Gym',
        NoteCategory.ideas => 'Ideas',
        NoteCategory.personal => 'Personal',
      };

  IconData get icon => switch (this) {
        NoteCategory.programming => Icons.code,
        NoteCategory.gym => Icons.fitness_center,
        NoteCategory.ideas => Icons.lightbulb_outline,
        NoteCategory.personal => Icons.person_outline,
      };

  Color get accentColor => switch (this) {
        NoteCategory.programming => const Color(0xFFE8B84B),
        NoteCategory.gym => const Color(0xFF7FBF7F),
        NoteCategory.ideas => const Color(0xFFD4537E),
        NoteCategory.personal => const Color(0xFF7B9FE0),
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
      attachedFilePaths: List<String>.from(json['attached_file_paths'] as List? ?? []),
    );
  }

  Map<String, dynamic> toInsertJson(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'category': category.name,
      'content': content.toDelta().toJson(),
      'attached_file_paths': attachedFilePaths,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'category': category.name,
      'content': content.toDelta().toJson(),
      'attached_file_paths': attachedFilePaths,
    };
  }

  String get preview {
    final plainText = content.toPlainText().trim();
    return plainText.length > 60
        ? '${plainText.substring(0, 60)}...'
        : plainText;
  }
}