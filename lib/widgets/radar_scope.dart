import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../domain/track_models.dart';
import '../theme/scope_palette.dart';
import '../theme/scope_type.dart';

class RadarScope extends StatelessWidget {
  final List<TrackVector> tracks;
  final List<ConflictProbe> conflicts;
  final List<SectorFix> fixes;
  final double sweepValue;
  final String? selectedCallsign;
  final int timelineMinutes;
  final ValueChanged<String>? onPickTrack;

  const RadarScope({
    super.key,
    required this.tracks,
    required this.conflicts,
    required this.fixes,
    required this.sweepValue,
    required this.timelineMinutes,
    this.selectedCallsign,
    this.onPickTrack,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapUp: (details) => _handleTap(details.localPosition, side),
          child: SizedBox(
            width: side,
            height: side,
            child: CustomPaint(
              painter: _ScopePainter(
                tracks: tracks,
                conflicts: conflicts,
                fixes: fixes,
                sweepValue: sweepValue,
                selectedCallsign: selectedCallsign,
                timelineMinutes: timelineMinutes,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(Offset local, double side) {
    if (onPickTrack == null) return;
    final center = Offset(side / 2, side / 2);
    final radius = side / 2 - 12;
    String? nearest;
    double best = 28;
    for (final t in tracks) {
      final px = center.dx + t.sectorX * radius;
      final py = center.dy + t.sectorY * radius;
      final d = (Offset(px, py) - local).distance;
      if (d < best) {
        best = d;
        nearest = t.callsign;
      }
    }
    if (nearest != null) onPickTrack!(nearest);
  }
}

class _ScopePainter extends CustomPainter {
  final List<TrackVector> tracks;
  final List<ConflictProbe> conflicts;
  final List<SectorFix> fixes;
  final double sweepValue;
  final String? selectedCallsign;
  final int timelineMinutes;

  _ScopePainter({
    required this.tracks,
    required this.conflicts,
    required this.fixes,
    required this.sweepValue,
    required this.selectedCallsign,
    required this.timelineMinutes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final bg = Paint()..color = ScopePalette.scopeBlack;
    canvas.drawCircle(center, radius, bg);

    _drawGrid(canvas, center, radius);
    _drawSweep(canvas, center, radius);
    _drawFixes(canvas, center, radius);
    _drawConflicts(canvas, center, radius);
    _drawTracks(canvas, center, radius);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = ScopePalette.phosphorDim;
    canvas.drawCircle(center, radius, rim);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = ScopePalette.grid;
    for (var r = 0.25; r <= 1.0; r += 0.25) {
      canvas.drawCircle(center, radius * r, ring);
    }
    for (var a = 0; a < 360; a += 30) {
      final rad = a * math.pi / 180;
      final end = Offset(
        center.dx + math.sin(rad) * radius,
        center.dy - math.cos(rad) * radius,
      );
      canvas.drawLine(center, end, ring);
    }
  }

  void _drawSweep(Canvas canvas, Offset center, double radius) {
    final angle = sweepValue * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final shader = SweepGradient(
      startAngle: angle - 0.7,
      endAngle: angle,
      colors: const [Color(0x0036F08A), Color(0x6636F08A)],
      transform: GradientRotation(-math.pi / 2),
    ).createShader(rect);
    final wedge = Paint()..shader = shader;
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, angle - math.pi / 2 - 0.7, 0.7, false)
      ..close();
    canvas.drawPath(path, wedge);

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = ScopePalette.phosphor.withValues(alpha: 0.6);
    final tip = Offset(
      center.dx + math.sin(angle) * radius,
      center.dy - math.cos(angle) * radius,
    );
    canvas.drawLine(center, tip, line);
  }

  void _drawFixes(Canvas canvas, Offset center, double radius) {
    final mark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = ScopePalette.cyanDim;
    for (final f in fixes) {
      final p = Offset(center.dx + f.x * radius, center.dy + f.y * radius);
      const s = 3.5;
      canvas.drawLine(Offset(p.dx - s, p.dy), Offset(p.dx + s, p.dy), mark);
      canvas.drawLine(Offset(p.dx, p.dy - s), Offset(p.dx, p.dy + s), mark);
      _label(canvas, f.code, Offset(p.dx + 6, p.dy - 12),
          ScopePalette.cyanDim, 8);
    }
  }

  void _drawConflicts(Canvas canvas, Offset center, double radius) {
    for (final c in conflicts) {
      final a = _find(c.callsignA);
      final b = _find(c.callsignB);
      if (a == null || b == null) continue;
      final pa = a.projected(timelineMinutes.toDouble());
      final pb = b.projected(timelineMinutes.toDouble());
      final oa = Offset(center.dx + pa.sectorX * radius, center.dy + pa.sectorY * radius);
      final ob = Offset(center.dx + pb.sectorX * radius, center.dy + pb.sectorY * radius);
      final mid = Offset((oa.dx + ob.dx) / 2, (oa.dy + ob.dy) / 2);
      final color = c.critical ? ScopePalette.alertRed : ScopePalette.amber;
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = c.critical ? 2.2 : 1.4
        ..color = color;
      canvas.drawCircle(mid, 16 + c.separationNm * radius, arc);
      final link = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = color.withValues(alpha: 0.5);
      canvas.drawLine(oa, ob, link);
    }
  }

  void _drawTracks(Canvas canvas, Offset center, double radius) {
    for (final t in tracks) {
      final p = Offset(center.dx + t.sectorX * radius, center.dy + t.sectorY * radius);
      final selected = t.callsign == selectedCallsign;
      final tint = selected ? ScopePalette.cyan : ScopePalette.phosphor;

      final future = t.projected(timelineMinutes.toDouble());
      final fp = Offset(center.dx + future.sectorX * radius, center.dy + future.sectorY * radius);
      final vector = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 1.4 : 0.9
        ..color = tint.withValues(alpha: selected ? 0.9 : 0.45);
      canvas.drawLine(p, fp, vector);

      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(t.headingRad);
      final glyph = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = tint;
      canvas.drawLine(const Offset(0, -5), const Offset(0, 5), glyph);
      canvas.drawLine(const Offset(-4, 2), const Offset(4, 2), glyph);
      canvas.restore();

      if (selected) {
        final halo = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = ScopePalette.cyan;
        canvas.drawCircle(p, 10, halo);
      }

      _label(canvas, t.callsign, Offset(p.dx + 8, p.dy - 6), tint, 8.5);
      _label(canvas, 'FL${t.flightLevel}', Offset(p.dx + 8, p.dy + 4),
          ScopePalette.readoutFaint, 7.5);
    }
  }

  void _label(Canvas canvas, String text, Offset at, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: ScopeType.tag(size, color: color, spacing: 0.5)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  TrackVector? _find(String callsign) {
    for (final t in tracks) {
      if (t.callsign == callsign) return t;
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant _ScopePainter old) => true;
}
