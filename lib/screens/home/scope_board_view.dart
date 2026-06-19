import 'package:flutter/material.dart';

import '../../domain/scope_engine.dart';
import '../../domain/sector_catalog.dart';
import '../../theme/scope_palette.dart';
import '../../theme/scope_type.dart';
import '../../widgets/radar_scope.dart';
import '../../widgets/scope_panel.dart';

class ScopeBoardView extends StatefulWidget {
  final ScopeEngine engine;
  final String? selected;
  final ValueChanged<String?> onPick;
  final ValueChanged<int> onSwapSector;

  const ScopeBoardView({
    super.key,
    required this.engine,
    required this.selected,
    required this.onPick,
    required this.onSwapSector,
  });

  @override
  State<ScopeBoardView> createState() => _ScopeBoardViewState();
}

class _ScopeBoardViewState extends State<ScopeBoardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final conflicts = engine.probeAhead(20);
    final selectedTrack =
        widget.selected == null ? null : engine.byCallsign(widget.selected!);

    return Column(
      children: [
        _sectorStrip(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedBuilder(
              animation: _sweep,
              builder: (context, child) {
                return RadarScope(
                  tracks: engine.tracks,
                  conflicts: conflicts,
                  fixes: engine.sector.fixes,
                  sweepValue: _sweep.value,
                  selectedCallsign: widget.selected,
                  timelineMinutes: 20,
                  onPickTrack: widget.onPick,
                );
              },
            ),
          ),
        ),
        _statusBar(engine, conflicts.length),
        if (selectedTrack != null) _trackReadout(selectedTrack),
      ],
    );
  }

  Widget _sectorStrip() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: SectorCatalog.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final s = SectorCatalog.all[i];
          final selected = s.code == widget.engine.sector.code;
          return GestureDetector(
            onTap: () => widget.onSwapSector(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ScopePalette.phosphorWash
                    : ScopePalette.panel,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected
                      ? ScopePalette.phosphor
                      : ScopePalette.hairline,
                ),
              ),
              child: Row(
                children: [
                  Text(s.code,
                      style: ScopeType.tag(13,
                          color: selected
                              ? ScopePalette.phosphor
                              : ScopePalette.readoutSoft)),
                  const SizedBox(width: 7),
                  Text(s.region.toUpperCase(),
                      style: ScopeType.caption(
                          color: selected
                              ? ScopePalette.phosphor
                              : ScopePalette.readoutFaint)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBar(ScopeEngine engine, int conflictCount) {
    final alert = conflictCount > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _stat('TRACKS', '${engine.tracks.length}', ScopePalette.phosphor),
          _stat(
            'CONFLICTS',
            '$conflictCount',
            alert ? ScopePalette.alertRed : ScopePalette.phosphorDim,
          ),
          _stat('RESOLVED', '${engine.resolvedConflicts}', ScopePalette.cyan),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: ScopePalette.panel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ScopePalette.hairline),
        ),
        child: Column(
          children: [
            Text(value, style: ScopeType.readout(20, color: color)),
            const SizedBox(height: 3),
            Text(label, style: ScopeType.caption()),
          ],
        ),
      ),
    );
  }

  Widget _trackReadout(track) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ScopePanel(
        color: ScopePalette.panelRaised,
        border: Border.all(color: ScopePalette.cyan),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.callsign,
                      style: ScopeType.tag(16, color: ScopePalette.cyan)),
                  const SizedBox(height: 2),
                  Text('${track.typeCode} · ${track.entryFix} → ${track.exitFix}',
                      style: ScopeType.caption()),
                ],
              ),
            ),
            _mini('FL', '${track.flightLevel}'),
            _mini('SPD', '${track.groundSpeedKts}'),
            _mini('HDG', track.headingDeg.round().toString().padLeft(3, '0')),
          ],
        ),
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(value, style: ScopeType.readout(15, color: ScopePalette.readout)),
          const SizedBox(height: 2),
          Text(label, style: ScopeType.caption()),
        ],
      ),
    );
  }
}
