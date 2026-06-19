import 'dart:math' as math;

import 'sector_catalog.dart';
import 'track_models.dart';

class ScopeEngine {
  final SectorDef sector;
  final math.Random _rng;
  final List<TrackVector> tracks = [];
  final List<OpsEvent> log = [];

  int costUsd = 0;
  double carbonKg = 0;
  int resolvedConflicts = 0;
  int tickCount = 0;

  ScopeEngine(this.sector, {int seed = 7}) : _rng = math.Random(seed) {
    for (var i = 0; i < 7; i++) {
      tracks.add(_spawn());
    }
  }

  TrackVector _spawn() {
    final carrier = SectorCatalog.carriers[_rng.nextInt(SectorCatalog.carriers.length)];
    final type = SectorCatalog.typePool[_rng.nextInt(SectorCatalog.typePool.length)];
    final entry = sector.fixes[_rng.nextInt(sector.fixes.length)];
    var exit = sector.fixes[_rng.nextInt(sector.fixes.length)];
    if (exit.code == entry.code) {
      exit = sector.fixes[(sector.fixes.indexOf(entry) + 2) % sector.fixes.length];
    }
    final heading = math.atan2(exit.x - entry.x, entry.y - exit.y) * 180 / math.pi;
    return TrackVector(
      callsign: '$carrier${100 + _rng.nextInt(8900)}',
      typeCode: type,
      headingDeg: (heading + 360) % 360,
      flightLevel: 280 + _rng.nextInt(13) * 10,
      groundSpeedKts: 380 + _rng.nextInt(180),
      sectorX: entry.x,
      sectorY: entry.y,
      entryFix: entry.code,
      exitFix: exit.code,
    );
  }

  void tick() {
    tickCount++;
    for (final t in tracks) {
      final nmPerMinute = t.groundSpeedKts / 60.0;
      final span = nmPerMinute * 0.5 / 120.0;
      t.sectorX = t.sectorX + math.sin(t.headingRad) * span;
      t.sectorY = t.sectorY - math.cos(t.headingRad) * span;
      if (t.sectorX.abs() > 1.05 || t.sectorY.abs() > 1.05) {
        final fresh = _spawn();
        t.sectorX = fresh.sectorX;
        t.sectorY = fresh.sectorY;
        t.headingDeg = fresh.headingDeg;
        t.flightLevel = fresh.flightLevel;
        t.groundSpeedKts = fresh.groundSpeedKts;
      }
    }
    if (tickCount % 14 == 0) {
      _rollOpsEvent();
    }
  }

  List<ConflictProbe> probeAhead(int minutes) {
    final out = <ConflictProbe>[];
    final future = tracks
        .map((t) => MapEntry(t, t.projected(minutes.toDouble())))
        .toList();
    for (var i = 0; i < future.length; i++) {
      for (var j = i + 1; j < future.length; j++) {
        final a = future[i];
        final b = future[j];
        final dx = a.value.sectorX - b.value.sectorX;
        final dy = a.value.sectorY - b.value.sectorY;
        final sep = math.sqrt(dx * dx + dy * dy);
        final levelGap = (a.key.flightLevel - b.key.flightLevel).abs();
        if (sep < 0.28 && levelGap < 10) {
          out.add(ConflictProbe(
            callsignA: a.key.callsign,
            callsignB: b.key.callsign,
            minutesAhead: minutes,
            separationNm: sep,
            levelGap: levelGap,
          ));
        }
      }
    }
    out.sort((x, y) => x.separationNm.compareTo(y.separationNm));
    return out;
  }

  TrackVector? byCallsign(String callsign) {
    for (final t in tracks) {
      if (t.callsign == callsign) return t;
    }
    return null;
  }

  void assignFlightLevel(String callsign, int level) {
    final t = byCallsign(callsign);
    if (t == null) return;
    t.flightLevel = level.clamp(180, 430);
    resolvedConflicts++;
    _push(OpsSeverity.routine, 'Clearance issued',
        '$callsign cleared to FL${t.flightLevel}.', 0, 0);
  }

  void assignSpeed(String callsign, int speed) {
    final t = byCallsign(callsign);
    if (t == null) return;
    t.groundSpeedKts = speed.clamp(220, 540);
    _push(OpsSeverity.routine, 'Speed restriction',
        '$callsign assigned $speed kts.', 0, 0);
  }

  void assignHeading(String callsign, int heading) {
    final t = byCallsign(callsign);
    if (t == null) return;
    t.headingDeg = (heading % 360).toDouble();
    resolvedConflicts++;
    _push(OpsSeverity.routine, 'Vector assigned',
        '$callsign turn heading ${heading.toString().padLeft(3, '0')}.', 0, 0);
  }

  void holdTrack(String callsign) {
    final t = byCallsign(callsign);
    if (t == null) return;
    t.delayMinutes += 4;
    costUsd += 4 * 1800;
    carbonKg += 4 * 92;
    _push(OpsSeverity.caution, 'Holding pattern',
        '$callsign placed in the stack (+4 min).', 4 * 1800, 4 * 92.0);
  }

  void _rollOpsEvent() {
    const pool = [
      ['Convective cell', 'Thunderstorm building over the arrival corridor.', OpsSeverity.caution],
      ['Tech failure', 'Crew reports a hydraulic caution and requests priority.', OpsSeverity.alert],
      ['Ground staff action', 'Reduced ramp capacity; expect inbound delays.', OpsSeverity.caution],
      ['Military activity', 'Restricted area activated inside the sector.', OpsSeverity.alert],
      ['Wake turbulence', 'Heavy departure ahead of a light type.', OpsSeverity.caution],
    ];
    final pick = pool[_rng.nextInt(pool.length)];
    final cost = (pick[2] == OpsSeverity.alert ? 9000 : 3200) + _rng.nextInt(2600);
    final carbon = (pick[2] == OpsSeverity.alert ? 240.0 : 110.0) + _rng.nextInt(90);
    _push(pick[2] as OpsSeverity, pick[0] as String, pick[1] as String, cost, carbon);
    costUsd += cost;
    carbonKg += carbon;
  }

  void _push(OpsSeverity sev, String head, String detail, int cost, double carbon) {
    log.insert(
      0,
      OpsEvent(
        id: '${DateTime.now().microsecondsSinceEpoch}-${log.length}',
        headline: head,
        detail: detail,
        severity: sev,
        costUsd: cost,
        carbonKg: carbon,
        stampedAt: DateTime.now(),
      ),
    );
    if (log.length > 40) log.removeLast();
  }
}
