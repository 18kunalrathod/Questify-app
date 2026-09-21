import 'package:flutter/material.dart';

import '../../shared/widgets/app_icons.dart';

enum QuestCategory { fitness, focus, knowledge, personal }

extension QuestCategoryX on QuestCategory {
  String get label => switch (this) {
        QuestCategory.fitness => 'Fitness',
        QuestCategory.focus => 'Focus',
        QuestCategory.knowledge => 'Knowledge',
        QuestCategory.personal => 'Personal',
      };

  AppIcon get icon => switch (this) {
        QuestCategory.fitness => AppIcon.streak,
        QuestCategory.focus => AppIcon.focus,
        QuestCategory.knowledge => AppIcon.document,
        QuestCategory.personal => AppIcon.checklist,
      };
}

enum QuestRarity { common, epic }

enum QuestPeriod { daily, weekly, monthly }

@immutable
class Quest {
  final String id;
  final String title;
  final String? description;
  final int xp;
  final QuestCategory category;
  final QuestRarity rarity;
  final QuestPeriod period;
  final bool completed;
  final double? progress;
  final String? dueLabel;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final bool isDailyChallenge;

  const Quest({
    required this.id,
    required this.title,
    this.description,
    required this.xp,
    required this.category,
    this.rarity = QuestRarity.common,
    required this.period,
    this.completed = false,
    this.progress,
    this.dueLabel,
    this.completedAt,
    this.createdAt,
    this.isDailyChallenge = false,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      xp: json['xp'] as int,
      category: QuestCategory.values.byName(json['category'] as String),
      rarity: QuestRarity.values.byName(json['rarity'] as String),
      period: QuestPeriod.values.byName(json['period'] as String),
      completed: json['completed'] as bool,
      progress: (json['progress'] as num?)?.toDouble(),
      dueLabel: json['due_label'] as String?,
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      isDailyChallenge: json['is_daily_challenge'] as bool? ?? false,
    );
  }

  Quest copyWith({bool? completed, double? progress, DateTime? completedAt}) {
    return Quest(
      id: id,
      title: title,
      description: description,
      xp: xp,
      category: category,
      rarity: rarity,
      period: period,
      completed: completed ?? this.completed,
      progress: progress ?? this.progress,
      dueLabel: dueLabel,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      isDailyChallenge: isDailyChallenge,
    );
  }
}