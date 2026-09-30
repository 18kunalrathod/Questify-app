import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/models/quest.dart';
import '../../../core/providers/quest_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';
import '../../../shared/widgets/hint_bubble.dart';
import 'focus_log_screen.dart';
import 'focus_log_sheet.dart';

enum SessionType { focus, breakTime, rest }

class AmbientSound {
  final String label;
  final IconData icon;
  final String? assetPath;
  const AmbientSound({required this.label, required this.icon, this.assetPath});
}

const _ambientSounds = [
  AmbientSound(label: 'Silence', icon: Icons.volume_off_outlined, assetPath: null),
  AmbientSound(label: 'Rain', icon: Icons.water_drop_outlined, assetPath: 'assets/sounds/rain.mp3'),
  AmbientSound(label: 'Forest', icon: Icons.forest_outlined, assetPath: 'assets/sounds/forest.mp3'),
  AmbientSound(label: 'White Noise', icon: Icons.graphic_eq, assetPath: 'assets/sounds/white_noise.mp3'),
];

const _focusPresets = [15, 25, 45, 60];
const _breakPresets = [5, 10, 15];
const _restPresets = [15, 30, 45];

/// Minimum time that must have elapsed before the checkmark can finish a
/// session and tick off a quest. Lower it only for quick testing.
const _minSessionSeconds = 60;

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> with TickerProviderStateMixin {
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _restMinutes = 30;

  late Duration _totalDuration = Duration(minutes: _focusMinutes);
  late Duration _remaining = _totalDuration;
  bool _isRunning = false;
  Timer? _countdownTimer;
  String _selectedSound = 'Silence';

  final AudioPlayer _audioPlayer = AudioPlayer();

  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    _audioPlayer.setLoopMode(LoopMode.one);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _rotateController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _startAmbientSound() async {
    final sound = _ambientSounds.firstWhere((s) => s.label == _selectedSound);
    if (sound.assetPath == null) return;

    try {
      await _audioPlayer.setAsset(sound.assetPath!);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Failed to play ambient sound: $e');
    }
  }

  Future<void> _stopAmbientSound() async {
    await _audioPlayer.stop();
  }

  Future<void> _switchAmbientSound(String label) async {
    setState(() => _selectedSound = label);
    if (_isRunning) {
      await _stopAmbientSound();
      await _startAmbientSound();
    }
  }

  void _toggleTimer() {
    if (_isRunning) {
      _countdownTimer?.cancel();
      _stopAmbientSound();
      setState(() => _isRunning = false);
      return;
    }

    setState(() => _isRunning = true);
    _startAmbientSound();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
        // The timer ran all the way down, so treat it exactly like tapping
        // the checkmark.
        _completeSession(elapsed: _totalDuration);
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    _stopAmbientSound();
    setState(() {
      _isRunning = false;
      _totalDuration = Duration(minutes: _focusMinutes);
      _remaining = _totalDuration;
    });
  }

  /// Checkmark button: finish the session early.
  void _finishSession() {
    final elapsed = _totalDuration - _remaining;
    if (elapsed.inSeconds < _minSessionSeconds) {
      _showMessage('Focus for at least a minute before finishing a session.');
      return;
    }
    _completeSession(elapsed: elapsed);
  }

  /// Ends the session, ticks off one of today's Focus quests when there is
  /// one, and shows a result sheet with the XP earned.
  Future<void> _completeSession({required Duration elapsed}) async {
    final minutes = math.max(1, elapsed.inMinutes);

    _countdownTimer?.cancel();
    await _stopAmbientSound();
    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _remaining = _totalDuration;
    });

    final dayStart = QuestNotifier.currentQuestDayStart();
    final candidates = ref
        .read(questProvider)
        .where((q) =>
            q.category == QuestCategory.focus &&
            q.period == QuestPeriod.daily &&
            !q.completed &&
            q.createdAt != null &&
            !q.createdAt!.isBefore(dayStart))
        .toList();

    var noXpReason = 'No Focus quest left today, so no XP this time.';
    Quest? chosen;

    if (candidates.length == 1) {
      chosen = candidates.first;
    } else if (candidates.length > 1) {
      chosen = await _pickQuest(candidates);
      if (!mounted) return;
      if (chosen == null) {
        noXpReason = 'No quest ticked off, so no XP this time.';
      }
    }

    Quest? completed;
    if (chosen != null) {
      try {
        await ref.read(questProvider.notifier).toggleComplete(chosen.id);
        completed = chosen;
      } catch (_) {
        if (!mounted) return;
        _showMessage("Couldn't update the quest. Please try again.");
        return;
      }
    }

    if (!mounted) return;
    await _showResultSheet(minutes: minutes, quest: completed, noXpReason: noXpReason);
  }

  Future<void> _showResultSheet({
    required int minutes,
    required Quest? quest,
    required String noXpReason,
  }) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.14)),
                  child: Icon(Icons.check, color: accent, size: 24),
                ),
                const SizedBox(height: 12),
                Text('Session complete', style: AppTextStyles.headline(context, size: 18)),
                const SizedBox(height: 4),
                Text('$minutes min focused', style: TextStyle(fontSize: 12, color: mutedColor)),
                const SizedBox(height: 18),
                if (quest != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '+${quest.xp} XP',
                          style: AppTextStyles.stat(context, size: 34, weight: FontWeight.w700, color: accent),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          quest.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text('Focus quest completed', style: TextStyle(fontSize: 11, color: mutedColor)),
                      ],
                    ),
                  )
                else
                  Text(
                    noXpReason,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: mutedColor),
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          showFocusLogSheet(context, ref, minutes: minutes, questTitle: quest?.title);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        ),
                        child: const Text('Add note'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: accent,
                          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                        ),
                        child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Quest?> _pickQuest(List<Quest> quests) {
    final accent = Theme.of(context).colorScheme.primary;
    return showModalBottomSheet<Quest>(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Which Focus quest did you finish?', style: AppTextStyles.headline(context, size: 16)),
                const SizedBox(height: 8),
                ...quests.map(
                  (q) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(q.title, style: const TextStyle(fontSize: 13)),
                    trailing: Text('+${q.xp} XP', style: AppTextStyles.stat(context, size: 12, color: accent)),
                    onTap: () => Navigator.of(sheetContext).pop(q),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Just end the session'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _cyclePreset(SessionType type) {
    if (_isRunning) return;
    setState(() {
      switch (type) {
        case SessionType.focus:
          final currentIndex = _focusPresets.indexOf(_focusMinutes);
          _focusMinutes = _focusPresets[(currentIndex + 1) % _focusPresets.length];
          _totalDuration = Duration(minutes: _focusMinutes);
          _remaining = _totalDuration;
        case SessionType.breakTime:
          final currentIndex = _breakPresets.indexOf(_breakMinutes);
          _breakMinutes = _breakPresets[(currentIndex + 1) % _breakPresets.length];
        case SessionType.rest:
          final currentIndex = _restPresets.indexOf(_restMinutes);
          _restMinutes = _restPresets[(currentIndex + 1) % _restPresets.length];
      }
    });
  }

  String get _formattedTime {
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final cardColor = Theme.of(context).cardTheme.color;
    final progress = _totalDuration.inSeconds == 0 ? 0.0 : _remaining.inSeconds / _totalDuration.inSeconds;

    return Scaffold(
      body: AmbientGlowBackground(
        strong: true,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DEEP WORK SANCTUM', style: TextStyle(color: mutedColor, fontSize: 10, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text('Flutter deep work', style: AppTextStyles.headline(context, size: 20)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FocusLogScreen()),
                    ),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: cardColor),
                      child: Icon(Icons.edit_note_outlined, size: 20, color: accent),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) => Transform.rotate(angle: _rotateController.value * 2 * math.pi, child: child),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent.withValues(alpha: 0.15), width: 1)),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(190, 190),
                      painter: _ProgressRingPainter(progress: progress, color: accent, trackColor: Colors.white.withValues(alpha: 0.06)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('FOCUS', style: TextStyle(color: mutedColor, fontSize: 11, letterSpacing: 2)),
                        const SizedBox(height: 6),
                        Text(_formattedTime, style: AppTextStyles.stat(context, size: 40)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleControlButton(icon: Icons.replay, onTap: _resetTimer, cardColor: cardColor, mutedColor: mutedColor),
                  const SizedBox(width: 18),
                  _CircleControlButton(icon: _isRunning ? Icons.pause : Icons.play_arrow, onTap: _toggleTimer, isPrimary: true, accent: accent),
                  const SizedBox(width: 18),
                  _CircleControlButton(icon: Icons.check, onTap: _finishSession, cardColor: cardColor, mutedColor: mutedColor),
                ],
              ),

              const SizedBox(height: 32),

              Text('SESSION SETTINGS', style: TextStyle(color: mutedColor, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _SettingRow(label: 'Focus', value: '$_focusMinutes min', onTap: () => _cyclePreset(SessionType.focus), showDivider: true),
                    _SettingRow(label: 'Break', value: '$_breakMinutes min', onTap: () => _cyclePreset(SessionType.breakTime), showDivider: true),
                    _SettingRow(label: 'Rest', value: '$_restMinutes min', onTap: () => _cyclePreset(SessionType.rest), showDivider: false),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text('AMBIENT SOUND', style: TextStyle(color: mutedColor, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 10),
              HintBubble(
                hintId: 'focus_sound_picker',
                message: 'Tap a sound to play it during focus',
                direction: AxisDirection.down,
                child: SizedBox(
                  height: 76,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _ambientSounds.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final sound = _ambientSounds[index];
                      final isSelected = _selectedSound == sound.label;
                      return GestureDetector(
                        onTap: () => _switchAmbientSound(sound.label),
                        child: Container(
                          width: 68,
                          decoration: BoxDecoration(
                            color: isSelected ? accent.withValues(alpha: 0.12) : cardColor,
                            border: Border.all(color: isSelected ? accent : Colors.transparent, width: 1.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(sound.icon, size: 18, color: isSelected ? accent : mutedColor),
                              const SizedBox(height: 6),
                              Text(sound.label, style: TextStyle(fontSize: 8, color: isSelected ? accent : mutedColor), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _ProgressRingPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) => oldDelegate.progress != progress;
}

class _CircleControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color? accent;
  final Color? cardColor;
  final Color? mutedColor;

  const _CircleControlButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.accent,
    this.cardColor,
    this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = isPrimary ? 64.0 : 48.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: isPrimary ? accent : cardColor),
        child: Icon(icon, size: isPrimary ? 28 : 20, color: isPrimary ? Colors.black.withValues(alpha: 0.8) : mutedColor),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingRow({required this.label, required this.value, required this.onTap, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))) : null),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16, color: mutedColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}