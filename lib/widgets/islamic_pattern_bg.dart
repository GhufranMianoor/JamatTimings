import 'dart:math';
import 'package:flutter/material.dart';

class IslamicPatternBackground extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final double opacity;

  const IslamicPatternBackground({
    super.key,
    this.child,
    this.color,
    this.opacity = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _IslamicPatternPainter(
        color: color ?? Theme.of(context).primaryColor,
        opacity: opacity,
      ),
      child: child,
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  _IslamicPatternPainter({required this.color, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double tileSize = 80.0;
    final int cols = (size.width / tileSize).ceil() + 1;
    final int rows = (size.height / tileSize).ceil() + 1;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final double cx = i * tileSize;
        final double cy = j * tileSize;
        _drawIslamicStar(canvas, Offset(cx, cy), tileSize / 2, paint);
      }
    }
  }

  void _drawIslamicStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw outer circle
    canvas.drawCircle(center, radius * 0.8, paint);

    // Draw an elegant octagon inside
    final octagonPath = Path();
    for (int i = 0; i < 8; i++) {
      final double angle = i * (2 * pi / 8) - pi / 8;
      final double dx = center.dx + radius * 0.8 * cos(angle);
      final double dy = center.dy + radius * 0.8 * sin(angle);
      if (i == 0) {
        octagonPath.moveTo(dx, dy);
      } else {
        octagonPath.lineTo(dx, dy);
      }
    }
    octagonPath.close();
    canvas.drawPath(octagonPath, paint);

    // Connecting lines for the geometric star grid (8-point star pattern)
    final starPath = Path();
    for (int i = 0; i < 8; i++) {
      final double angle1 = i * (2 * pi / 8);
      final double angle2 = (i + 3) * (2 * pi / 8);

      starPath.moveTo(
        center.dx + radius * 0.8 * cos(angle1),
        center.dy + radius * 0.8 * sin(angle1),
      );
      starPath.lineTo(
        center.dx + radius * 0.8 * cos(angle2),
        center.dy + radius * 0.8 * sin(angle2),
      );
    }
    canvas.drawPath(starPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
