import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/duty_archive.dart';
import '../../domain/duty_record.dart';
import '../../domain/scope_engine.dart';
import '../../state/duty_scope.dart';
import '../../theme/scope_palette.dart';
import '../../theme/scope_type.dart';
import '../../widgets/gauge_ring.dart';
import '../../widgets/scope_panel.dart';
import '../../widgets/sweep_button.dart';

class DutyArchiveView extends StatelessWidget {
  final ScopeEngine engine;
  final bool hardcore;
  final ValueChanged<bool> onHardcore;

  const DutyArchiveView({
    super.key,
    required this.engine,
    required this.hardcore,
    required this.onHardcore,
  });

  String _grade(int rating) {
    if (rating >= 1400) return 'AREA SUPERVISOR';
    if (rating >= 900) return 'SENIOR CONTROLLER';
    if (rating >= 450) return 'CONTROLLER';
    if (rating >= 150) return 'TRAINEE';
    return 'CADET';
  }

  Future<void> _fileWatch(BuildContext context, DutyArchive archive) async {
    await archive.fileWatch(
      sectorCode: engine.sector.code,
      trafficHandled: engine.tracks.length,
      conflictsResolved: engine.resolvedConflicts,
      costUsd: engine.costUsd,
      carbonKg: engine.carbonKg,
      hardcore: hardcore,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Watch filed to your duty archive.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final archive = DutyScope.of(context);
    final rating = archive.careerRating;
    final progress = (rating % 450) / 450.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        ScopePanel(
          child: Row(
            children: [
              GaugeRing(
                size: 96,
                fraction: progress,
                stroke: 9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$rating',
                        style: ScopeType.readout(22, color: ScopePalette.phosphor)),
                    Text('PTS', style: ScopeType.caption()),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_grade(rating),
                        style: ScopeType.heading(color: ScopePalette.phosphor)),
                    const SizedBox(height: 8),
                    _line('${archive.watchesLogged} watches filed',
                        Icons.event_available_rounded, ScopePalette.cyan),
                    const SizedBox(height: 4),
                    _line('${archive.conflictsTotal} conflicts resolved',
                        Icons.alt_route_rounded, ScopePalette.phosphor),
                    const SizedBox(height: 4),
                    _line('${archive.sectorsWorked.length} sectors worked',
                        Icons.public_rounded, ScopePalette.amber),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ScopePanel(
          border: Border.all(
              color: hardcore ? ScopePalette.alertRed : ScopePalette.hairline),
          child: Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  color: hardcore ? ScopePalette.alertRed : ScopePalette.readoutFaint),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HARDCORE MODE', style: ScopeType.heading()),
                    const SizedBox(height: 3),
                    Text('One collision ends the watch. No saves, bonus rating.',
                        style: ScopeType.caption()),
                  ],
                ),
              ),
              Switch(
                value: hardcore,
                activeThumbColor: ScopePalette.alertRed,
                onChanged: onHardcore,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SweepButton(
          label: 'File current watch',
          icon: Icons.save_alt_rounded,
          onPressed: () => _fileWatch(context, archive),
        ),
        const SizedBox(height: 20),
        Text('DUTY ARCHIVE', style: ScopeType.label()),
        const SizedBox(height: 10),
        if (archive.records.isEmpty)
          ScopePanel(
            child: Text(
              'No filed watches yet. Work the scope, then file the watch to build your career rating.',
              style: ScopeType.body(),
            ),
          )
        else
          ...archive.records.map((r) => _recordTile(archive, r)),
      ],
    );
  }

  Widget _line(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text,
              style: ScopeType.bodyStrong(color: ScopePalette.readout),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _recordTile(DutyArchive archive, DutyRecord r) {
    return Dismissible(
      key: ValueKey(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(
          color: ScopePalette.alertWash,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: ScopePalette.alertRed),
      ),
      onDismissed: (_) => archive.strike(r.id),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ScopePanel(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r.sectorCode,
                            style: ScopeType.tag(13, color: ScopePalette.phosphor)),
                        if (r.hardcore) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.local_fire_department_rounded,
                              size: 13, color: ScopePalette.alertRed),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${r.trafficHandled} tracks · ${r.conflictsResolved} resolved · ${DateFormat('MMM d').format(r.flownAt)}',
                      style: ScopeType.caption(),
                    ),
                  ],
                ),
              ),
              Text('${r.rating}',
                  style: ScopeType.readout(18, color: ScopePalette.cyan)),
              const SizedBox(width: 4),
              Text('PTS', style: ScopeType.caption()),
            ],
          ),
        ),
      ),
    );
  }
}
