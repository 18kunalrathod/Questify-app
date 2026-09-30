import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'focus_log_provider.dart';
import 'models/focus_log.dart';

/// Opens the sheet for writing a focus log entry. Used for new entries
/// (manual or after a session) and for editing an existing one.
Future<void> showFocusLogSheet(
  BuildContext context,
  WidgetRef ref, {
  FocusLog? existing,
  int? minutes,
  String? questTitle,
}) async {
  final noteController = TextEditingController(text: existing?.note ?? '');
  final startMinutes = existing?.minutes ?? minutes;
  final minutesController = TextEditingController(text: startMinutes?.toString() ?? '');
  final quest = existing?.questTitle ?? questTitle;
  bool isSaving = false;
  String? error;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final accent = Theme.of(context).colorScheme.primary;
            final mutedColor = Theme.of(context).textTheme.bodySmall?.color;

            Future<void> save() async {
              final note = noteController.text.trim();
              if (note.isEmpty) {
                setSheetState(() => error = 'Write a quick note first.');
                return;
              }

              int? parsedMinutes;
              final minutesText = minutesController.text.trim();
              if (minutesText.isNotEmpty) {
                parsedMinutes = int.tryParse(minutesText);
                if (parsedMinutes == null || parsedMinutes < 1 || parsedMinutes > 720) {
                  setSheetState(() => error = 'Minutes must be between 1 and 720.');
                  return;
                }
              }

              setSheetState(() {
                isSaving = true;
                error = null;
              });

              try {
                final notifier = ref.read(focusLogProvider.notifier);
                if (existing != null) {
                  await notifier.updateLog(
                    FocusLog(
                      id: existing.id,
                      note: note,
                      minutes: parsedMinutes,
                      questTitle: existing.questTitle,
                      loggedAt: existing.loggedAt,
                    ),
                  );
                } else {
                  await notifier.addLog(note: note, minutes: parsedMinutes, questTitle: quest);
                }
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              } catch (_) {
                setSheetState(() {
                  isSaving = false;
                  error = "Couldn't save. Please try again.";
                });
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing != null ? 'Edit log' : 'Focus log', style: AppTextStyles.headline(context, size: 17)),
                const SizedBox(height: 14),
                TextField(
                  controller: noteController,
                  autofocus: true,
                  maxLines: 5,
                  minLines: 3,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'What did you work on? Anything goes.',
                  ),
                ),
                if (quest != null) ...[
                  const SizedBox(height: 4),
                  Text('Counts toward: $quest', style: TextStyle(fontSize: 11, color: mutedColor)),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Minutes (optional)', style: TextStyle(fontSize: 12, color: mutedColor)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: minutesController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(isDense: true, hintText: '25'),
                      ),
                    ),
                  ],
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(error!, style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isSaving ? null : () => Navigator.of(sheetContext).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        ),
                        child: isSaving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                ),
                              )
                            : Text(
                                existing != null ? 'Save changes' : 'Save log',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}