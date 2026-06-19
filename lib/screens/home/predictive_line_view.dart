import 'package:flutter/material.dart';

import '../../domain/scope_engine.dart';
import '../../theme/scope_palette.dart';
import '../../theme/scope_type.dart';
import '../../widgets/radar_scope.dart';
import '../../widgets/scope_panel.dart';

class PredictiveLineView extends StatefulWidget {
  final ScopeEngine engine;
  final String? selected;
  final ValueChanged<String?> onPick;

  const PredictiveLineView({
    super.key,
    required this.engine,
    required this.selected,
    required this.onPick,
  });

  @override
  State<PredictiveLineView> createState() => _PredictiveLineViewState();
}

class _PredictiveLineViewState extends State<PredictiveLineView> {
  double _minutes = 30;

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final conflicts = engine.probeAhead(_minutes.round());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        ScopePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.timeline_rounded,
                      color: ScopePalette.phosphor, size: 18),
                  const SizedBox(width: 8),
                  Text('PREDICTIVE TIMELINE', style: ScopeType.heading()),
                  const Spacer(),
                  Text('+${_minutes.round()} MIN',
                      style: ScopeType.readout(16, color: ScopePalette.amber)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Project every track forward and surface conflicts before they happen. Slide to scan 10 to 40 minutes ahead.',
                style: ScopeType.body(),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: ScopePalette.phosphor,
                  inactiveTrackColor: ScopePalette.grid,
                  thumbColor: ScopePalette.phosphor,
                  overlayColor: ScopePalette.phosphorWash,
                ),
                child: Slider(
                  value: _minutes,
                  min: 10,
                  max: 40,
                  divisions: 6,
                  onChanged: (v) => setState(() => _minutes = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AspectRatio(
          aspectRatio: 1,
          child: RadarScope(
            tracks: engine.tracks,
            conflicts: conflicts,
            fixes: engine.sector.fixes,
            sweepValue: 0,
            selectedCallsign: widget.selected,
            timelineMinutes: _minutes.round(),
            onPickTrack: widget.onPick,
          ),
        ),
        const SizedBox(height: 16),
        Text('PROJECTED CONFLICTS', style: ScopeType.label()),
        const SizedBox(height: 10),
        if (conflicts.isEmpty)
          ScopePanel(
            color: ScopePalette.phosphorWash,
            border: Border.all(color: ScopePalette.phosphorDim),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: ScopePalette.phosphor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Sector is clean at this look-ahead.',
                      style: ScopeType.bodyStrong(color: ScopePalette.phosphor)),
                ),
              ],
            ),
          )
        else
          ...conflicts.map((c) {
            final color =
                c.critical ? ScopePalette.alertRed : ScopePalette.amber;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ScopePanel(
                onTap: () => widget.onPick(c.callsignA),
                border: Border.all(color: color),
                child: Row(
                  children: [
                    Icon(
                        c.critical
                            ? Icons.warning_rounded
                            : Icons.error_outline_rounded,
                        color: color,
                        size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.callsignA}  ×  ${c.callsignB}',
                              style: ScopeType.tag(13, color: color)),
                          const SizedBox(height: 3),
                          Text(
                            'LEVEL GAP ${c.levelGap.toString().padLeft(3, '0')} · in ${c.minutesAhead} min',
                            style: ScopeType.caption(),
                          ),
                        ],
                      ),
                    ),
                    Text(c.critical ? 'CRITICAL' : 'ADVISORY',
                        style: ScopeType.label(color: color)),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
