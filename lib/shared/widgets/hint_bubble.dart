import 'package:flutter/material.dart';
import '../../core/utils/hint_service.dart';

/// A one-time coach-mark bubble that appears above/below the child it
/// wraps, pointing at it, until the user dismisses it (by tapping the
/// bubble or the child) or has already seen it on a previous visit.
class HintBubble extends StatefulWidget {
  final String hintId;
  final String message;
  final Widget child;

  /// Which side of the child the bubble appears on.
  final AxisDirection direction;

  const HintBubble({
    super.key,
    required this.hintId,
    required this.message,
    required this.child,
    this.direction = AxisDirection.up,
  });

  @override
  State<HintBubble> createState() => _HintBubbleState();
}

class _HintBubbleState extends State<HintBubble> {
  bool _shouldShow = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkIfShouldShow();
  }

  Future<void> _checkIfShouldShow() async {
    final seen = await HintService.hasSeen(widget.hintId);
    if (!mounted) return;
    setState(() {
      _shouldShow = !seen;
      _checked = true;
    });
  }

  Future<void> _dismiss() async {
    await HintService.markSeen(widget.hintId);
    if (!mounted) return;
    setState(() => _shouldShow = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || !_shouldShow) {
      return widget.child;
    }

    final isPointingUp = widget.direction == AxisDirection.up;
    final bubble = GestureDetector(
      onTap: _dismiss,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          widget.message,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ),
    );

    final arrow = CustomPaint(
      size: const Size(14, 7),
      painter: _ArrowPainter(
        color: Theme.of(context).colorScheme.primary,
        pointingUp: !isPointingUp,
      ),
    );

    return GestureDetector(
      onTap: _dismiss,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isPointingUp
            ? [bubble, arrow, widget.child]
            : [widget.child, arrow, bubble],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final bool pointingUp;

  _ArrowPainter({required this.color, required this.pointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (pointingUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointingUp != pointingUp;
}