import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../runtime/sector_gate.dart';
import '../runtime/trace_beacon.dart';
import '../theme/scope_palette.dart';
import '../theme/scope_type.dart';
import 'content/scope_surface_view.dart';
import 'lost_link_screen.dart';
import 'native_root.dart';

class PreflightGateScreen extends StatefulWidget {
  const PreflightGateScreen({super.key});

  @override
  State<PreflightGateScreen> createState() => _PreflightGateScreenState();
}

class _PreflightGateScreenState extends State<PreflightGateScreen>
    with SingleTickerProviderStateMixin {
  late Future<GateResult> _future;
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _future = SectorGate.resolve();
  }

  void _retry() {
    setState(() {
      _future = SectorGate.resolve();
    });
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GateResult>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _splash();
        }
        final result = snap.data ?? const GateResult(GateOutcome.native);
        switch (result.outcome) {
          case GateOutcome.lostLink:
            return LostLinkScreen(onRetry: _retry);
          case GateOutcome.content:
            TraceBeacon.contentOpen();
            return ScopeSurfaceView(endpoint: result.endpoint!);
          case GateOutcome.native:
            return const NativeRoot();
        }
      },
    );
  }

  Widget _splash() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ScopePalette.scopeGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: AnimatedBuilder(
                  animation: _sweep,
                  builder: (context, child) {
                    return CustomPaint(painter: _BootSweep(_sweep.value));
                  },
                ),
              ),
              const SizedBox(height: 26),
              Text('ACQUIRING SECTOR LINK',
                  style: ScopeType.label(color: ScopePalette.phosphor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BootSweep extends CustomPainter {
  final double value;
  _BootSweep(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = ScopePalette.grid;
    for (var r = 0.4; r <= 1.0; r += 0.3) {
      canvas.drawCircle(center, radius * r, ring);
    }
    final angle = value * 2 * math.pi;
    final tip = Offset(
      center.dx + (radius * 0.95) * math.sin(angle),
      center.dy - (radius * 0.95) * math.cos(angle),
    );
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = ScopePalette.phosphor;
    canvas.drawLine(center, tip, line);
  }

  @override
  bool shouldRepaint(covariant _BootSweep old) => old.value != value;
}
