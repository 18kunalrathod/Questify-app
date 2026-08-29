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
  });

  // Creates a copy with some fields replaced — used when toggling completion.
  Quest copyWith({bool? completed, double? progress}) {
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
    );
  }
}