import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/scope_palette.dart';
import '../../theme/scope_type.dart';
import '../../widgets/sweep_button.dart';

class _Brief {
  final IconData icon;
  final String title;
  final String body;
  const _Brief(this.icon, this.title, this.body);
}

class BriefingDeck extends StatefulWidget {
  final VoidCallback onDone;
  const BriefingDeck({super.key, required this.onDone});

  @override
  State<BriefingDeck> createState() => _BriefingDeckState();
}

class _BriefingDeckState extends State<BriefingDeck>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  late final AnimationController _sweep;
  int _index = 0;

  static const _briefs = [
    _Brief(Icons.radar_rounded, 'Own the sector',
        'You are the controller, not the pilot. Keep dozens of tracks moving safely through a busy upper sector over Europe or the US.'),
    _Brief(Icons.timeline_rounded, 'Read the future',
        'Tap a track to project its path 30 to 40 minutes ahead. Conflicting trajectories light up as pulsing arcs — resolve them before they happen.'),
    _Brief(Icons.alt_route_rounded, 'Issue clearances',
        'Assign flight levels, speeds and vectors from the clearance queue. Move tracks apart by altitude or heading with one tap.'),
    _Brief(Icons.warning_amber_rounded, 'Mind the cost of error',
        'Storms, tech failures and military activity hit in real time. Every delayed minute burns money and carbon. Push Hardcore for no second chances.'),
  ];

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  bool get _last => _index == _briefs.length - 1;

  void _next() {
    if (_last) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ScopePalette.scopeGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: AnimatedOpacity(
                    opacity: _last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: ScopeLink(
                      label: 'Skip',
                      onPressed: _last ? null : widget.onDone,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _briefs.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final b = _briefs[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 168,
                            height: 168,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _sweep,
                                  builder: (context, child) => CustomPaint(
                                    size: const Size(168, 168),
                                    painter: _BriefScope(_sweep.value),
                                  ),
                                ),
                                Icon(b.icon,
                                    size: 52, color: ScopePalette.phosphor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(b.title.toUpperCase(),
                              style: ScopeType.title(),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 14),
                          Text(b.body,
                              style: ScopeType.body(),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_briefs.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 8,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? ScopePalette.phosphor
                          : ScopePalette.grid,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 24, 30, 28),
                child: SweepButton(
                  label: _last ? 'Take control' : 'Next',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BriefScope extends CustomPainter {
  final double value;
  _BriefScope(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = ScopePalette.grid;
    for (var r = 0.4; r <= 1.0; r += 0.3) {
      canvas.drawCircle(center, radius * r, ring);
    }
    final angle = value * 2 * math.pi;
    final tip = Offset(
      center.dx + radius * math.sin(angle),
      center.dy - radius * math.cos(angle),
    );
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = ScopePalette.phosphor.withValues(alpha: 0.7);
    canvas.drawLine(center, tip, line);
  }

  @override
  bool shouldRepaint(covariant _BriefScope old) => old.value != value;
}
