import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/scope_palette.dart';

class GaugeRing extends StatelessWidget {
  final double size;
  final double fraction;
  final Color color;
  final Color track;
  final double stroke;
  final Widget? child;

  const GaugeRing({
    super.key,
    required this.size,
    required this.fraction,
    this.color = ScopePalette.phosphor,
    this.track = ScopePalette.grid,
    this.stroke = 9,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: fraction.clamp(0, 1).toDouble(),
          color: color,
          track: track,
          stroke: stroke,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color track;
  final double stroke;

  _RingPainter({
    required this.fraction,
    required this.color,
    required this.track,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    const startAngle = math.pi * 0.75;
    const totalSweep = math.pi * 1.5;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, totalSweep, false, trackPaint);

    if (fraction <= 0) return;

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, totalSweep * fraction, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.fraction != fraction ||
      old.color != color ||
      old.track != track ||
      old.stroke != stroke;
}
