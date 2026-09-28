import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/quest_provider.dart';
import '../../calendar/presentation/calendar_provider.dart';
import '../../notes/presentation/note_provider.dart';

/// Collects the user's quests, notes and calendar events into one JSON
/// file and opens the system share sheet so they can save or send it.
Future<void> exportUserData(WidgetRef ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  final quests = ref.read(questProvider);
  final notes = ref.read(noteProvider);
  final events = ref.read(calendarProvider);

  final data = {
    'exported_at': DateTime.now().toIso8601String(),
    'account_email': user?.email,
    'quests': [
      for (final q in quests)
        {
          'title': q.title,
          'xp': q.xp,
          'category': q.category.name,
          'period': q.period.name,
          'completed': q.completed,
          'completed_at': q.completedAt?.toIso8601String(),
          'created_at': q.createdAt?.toIso8601String(),
          'is_daily_challenge': q.isDailyChallenge,
        },
    ],
    'notes': [
      for (final n in notes)
        {
          'title': n.title,
          'category': n.category.name,
          'text': n.content.toPlainText().trim(),
          'updated_at': n.updatedAt.toIso8601String(),
        },
    ],
    'calendar_events': [
      for (final e in events)
        {
          'title': e.title,
          'date': e.date.toIso8601String(),
          'time': e.time,
          'is_quest_deadline': e.isQuestDeadline,
        },
    ],
  };

  final json = const JsonEncoder.withIndent('  ').convert(data);
  final stamp = DateTime.now().toIso8601String().split('T').first;
  final file = File('${Directory.systemTemp.path}/questify_export_$stamp.json');
  await file.writeAsString(json);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      subject: 'Questify data export',
    ),
  );
}