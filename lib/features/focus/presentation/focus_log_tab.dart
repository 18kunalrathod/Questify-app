import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'focus_log_provider.dart';
import 'focus_log_sheet.dart';
import 'models/focus_log.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  if (_sameDay(date, now)) return 'TODAY';
  if (_sameDay(date, now.subtract(const Duration(days: 1)))) return 'YESTERDAY';
  return '${_months[date.month - 1].toUpperCase()} ${date.day}';
}

String _formatMinutes(int total) {
  if (total < 60) return '$total min';
  final hours = total ~/ 60;
  final rest = total % 60;
  return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
}

class FocusLogTab extends ConsumerWidget {
  const FocusLogTab({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete log?'),
        content: const Text('This entry will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final logs = ref.watch(focusLogProvider);

    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    var todayMinutes = 0;
    var weekMinutes = 0;
    for (final log in logs) {
      final m = log.minutes ?? 0;
      if (_sameDay(log.loggedAt, now)) todayMinutes += m;
      if (!log.loggedAt.isBefore(startOfWeek)) weekMinutes += m;
    }

    final items = <Object>[];
    String? lastLabel;
    for (final log in logs) {
      final label = _dayLabel(log.loggedAt);
      if (label != lastLabel) {
        items.add(label);
        lastLabel = label;
      }
      items.add(log);
    }

    return Stack(
      children: [
        SafeArea(
          child: logs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note_outlined, size: 34, color: mutedColor),
                        const SizedBox(height: 12),
                        const Text('No focus logs yet.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Tap + to write one, or finish a focus session and add a note.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatBox(label: 'Today', value: _formatMinutes(todayMinutes), valueColor: accent, cardColor: cardColor, mutedColor: mutedColor),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatBox(label: 'This week', value: _formatMinutes(weekMinutes), cardColor: cardColor, mutedColor: mutedColor),
                            ),
                          ],
                        ),
                      );
                    }

                    final item = items[index - 1];

                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 8),
                        child: Text(item, style: TextStyle(fontSize: 10, letterSpacing: 1, color: mutedColor)),
                      );
                    }

                    final log = item as FocusLog;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: ValueKey(log.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmDelete(context),
                        onDismissed: (_) async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await ref.read(focusLogProvider.notifier).deleteLog(log.id);
                          } catch (_) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text("Couldn't delete this log. Please try again.")),
                            );
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                        child: GestureDetector(
                          onTap: () => showFocusLogSheet(context, ref, existing: log),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      TimeOfDay.fromDateTime(log.loggedAt).format(context),
                                      style: TextStyle(fontSize: 11, color: mutedColor),
                                    ),
                                    if (log.minutes != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: accent.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          '${log.minutes} min',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                Text(log.note, style: const TextStyle(fontSize: 12, height: 1.5)),
                                if (log.questTitle != null) ...[
                                  const SizedBox(height: 8),
                                  Text(log.questTitle!, style: TextStyle(fontSize: 10, color: mutedColor)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => showFocusLogSheet(context, ref),
            backgroundColor: accent,
            child: Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Color? cardColor;
  final Color? mutedColor;

  const _StatBox({
    required this.label,
    required this.value,
    this.valueColor,
    required this.cardColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: mutedColor)),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.stat(context, size: 16, color: valueColor)),
        ],
      ),
    );
  }
}