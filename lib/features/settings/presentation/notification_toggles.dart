import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/quest_provider.dart';
import '../../../core/services/notification_service.dart';

class NotificationToggles extends ConsumerStatefulWidget {
  const NotificationToggles({super.key});

  @override
  ConsumerState<NotificationToggles> createState() => _NotificationTogglesState();
}

class _NotificationTogglesState extends ConsumerState<NotificationToggles> {
  bool _daily = false;
  bool _streak = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = NotificationService.instance;
    final daily = await service.isDailyEnabled();
    final streak = await service.isStreakEnabled();
    if (!mounted) return;
    setState(() {
      _daily = daily;
      _streak = streak;
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _setDaily(bool value) async {
    try {
      final ok = await NotificationService.instance.setDailyEnabled(value);
      if (!ok) {
        _showMessage("Notifications are blocked for Questify. Turn them on in your phone's Settings, then try again.");
        return;
      }
      if (!mounted) return;
      setState(() => _daily = value);
    } catch (_) {
      _showMessage("Couldn't change this setting. Please try again.");
    }
  }

  Future<void> _setStreak(bool value) async {
    try {
      final quests = ref.read(questProvider);
      final ok = await NotificationService.instance.setStreakEnabled(value, quests);
      if (!ok) {
        _showMessage("Notifications are blocked for Questify. Turn them on in your phone's Settings, then try again.");
        return;
      }
      if (!mounted) return;
      setState(() => _streak = value);
    } catch (_) {
      _showMessage("Couldn't change this setting. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToggleRow(
          label: 'Daily quest reminders',
          value: _daily,
          onChanged: _setDaily,
          showDivider: true,
        ),
        _ToggleRow(
          label: 'Streak warnings',
          value: _streak,
          onChanged: _setStreak,
          showDivider: false,
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Switch(value: value, onChanged: onChanged, activeThumbColor: accent),
        ],
      ),
    );
  }
}