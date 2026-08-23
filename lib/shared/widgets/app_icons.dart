import 'package:flutter/material.dart';

enum AppIcon { streak, focus, quest, document, checklist, back }

class AppIconWidget extends StatelessWidget {
  final AppIcon icon;
  final double size;
  final Color color;

  const AppIconWidget({
    super.key,
    required this.icon,
    this.size = 16,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AppIconPainter(icon: icon, color: color),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  final AppIcon icon;
  final Color color;

  _AppIconPainter({required this.icon, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    switch (icon) {
      case AppIcon.streak:
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.38, paint);
        canvas.drawLine(Offset(w / 2, h * 0.1), Offset(w / 2, h * 0.9), paint);
        canvas.drawLine(Offset(w * 0.1, h / 2), Offset(w * 0.9, h / 2), paint);
        break;
      case AppIcon.focus:
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.38, paint);
        final path = Path()
          ..moveTo(w / 2, h * 0.3)
          ..lineTo(w / 2, h / 2)
          ..lineTo(w * 0.68, h * 0.62);
        canvas.drawPath(path, paint);
        break;
      case AppIcon.quest:
        final path = Path()
          ..moveTo(w / 2, h * 0.08)
          ..lineTo(w * 0.9, h * 0.3)
          ..lineTo(w * 0.9, h * 0.75)
          ..lineTo(w / 2, h * 0.95)
          ..lineTo(w * 0.1, h * 0.75)
          ..lineTo(w * 0.1, h * 0.3)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case AppIcon.document:
        final path = Path()
          ..moveTo(w * 0.15, h * 0.1)
          ..lineTo(w * 0.6, h * 0.1)
          ..lineTo(w * 0.85, h * 0.35)
          ..lineTo(w * 0.85, h * 0.9)
          ..lineTo(w * 0.15, h * 0.9)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawLine(Offset(w * 0.6, h * 0.1), Offset(w * 0.6, h * 0.35), paint);
        canvas.drawLine(Offset(w * 0.6, h * 0.35), Offset(w * 0.85, h * 0.35), paint);
        break;
      case AppIcon.checklist:
        final rect = Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(w * 0.12)), paint);
        final check = Path()
          ..moveTo(w * 0.3, h * 0.5)
          ..lineTo(w * 0.45, h * 0.65)
          ..lineTo(w * 0.72, h * 0.35);
        canvas.drawPath(check, paint);
        break;
      case AppIcon.back:
        final path = Path()
          ..moveTo(w * 0.65, h * 0.15)
          ..lineTo(w * 0.3, h * 0.5)
          ..lineTo(w * 0.65, h * 0.85);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _AppIconPainter oldDelegate) {
    return oldDelegate.icon != icon || oldDelegate.color != color;
  }
}