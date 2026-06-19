import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/scope_palette.dart';

class TrackBlip extends StatelessWidget {
  final double size;
  final Color color;
  final double headingDeg;

  const TrackBlip({
    super.key,
    this.size = 26,
    this.color = ScopePalette.phosphor,
    this.headingDeg = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: headingDeg * math.pi / 180,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _BlipPainter(color)),
      ),
    );
  }
}

class _BlipPainter extends CustomPainter {
  final Color color;
  _BlipPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(w * 0.5, h * 0.08);
    path.lineTo(w * 0.5, h * 0.78);
    path.moveTo(w * 0.16, h * 0.5);
    path.lineTo(w * 0.84, h * 0.5);
    path.moveTo(w * 0.34, h * 0.86);
    path.lineTo(w * 0.66, h * 0.86);
    canvas.drawPath(path, paint);

    final dot = Paint()..color = color;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 2.0, dot);
  }

  @override
  bool shouldRepaint(covariant _BlipPainter old) => old.color != color;
}
