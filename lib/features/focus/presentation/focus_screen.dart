import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ambient_glow_background.dart';

enum SessionType { focus, breakTime, rest }

class AmbientSound {
  final String label;
  final IconData icon;
  const AmbientSound({required this.label, required this.icon});
}

const _ambientSounds = [
  AmbientSound(label: 'Silence', icon: Icons.volume_off_outlined),
  AmbientSound(label: 'Rain', icon: Icons.water_drop_outlined),
  AmbientSound(label: 'Forest', icon: Icons.forest_outlined),
  AmbientSound(label: 'White Noise', icon: Icons.graphic_eq),
];

const _focusPresets = [15, 25, 45, 60];
const _breakPresets = [5, 10, 15];
const _restPresets = [15, 30, 45];

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _restMinutes = 30;

  late Duration _totalDuration = Duration(minutes: _focusMinutes);
  late Duration _remaining = _totalDuration;
  bool _isRunning = false;
  Timer? _countdownTimer;
  String _selectedSound = 'Silence';

  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _rotateController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _countdownTimer?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    setState(() => _isRunning = true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isRunning = false;
          _remaining = Duration.zero;
        });
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _resetTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _isRunning = false;
      _totalDuration = Duration(minutes: _focusMinutes);
      _remaining = _totalDuration;
    });
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
              Text('DEEP WORK SANCTUM', style: TextStyle(color: mutedColor, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('Flutter deep work', style: AppTextStyles.headline(context, size: 20)),

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
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent.withOpacity(0.15), width: 1)),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(190, 190),
                      painter: _ProgressRingPainter(progress: progress, color: accent, trackColor: Colors.white.withOpacity(0.06)),
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
                  _CircleControlButton(icon: Icons.check, onTap: () {}, cardColor: cardColor, mutedColor: mutedColor),
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
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _ambientSounds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final sound = _ambientSounds[index];
                    final isSelected = _selectedSound == sound.label;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSound = sound.label),
                      child: Container(
                        width: 68,
                        decoration: BoxDecoration(
                          color: isSelected ? accent.withOpacity(0.12) : cardColor,
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
        child: Icon(icon, size: isPrimary ? 28 : 20, color: isPrimary ? Colors.black.withOpacity(0.8) : mutedColor),
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
        decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))) : null),
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