import 'dart:math' as math;

class TrackVector {
  final String callsign;
  final String typeCode;
  double headingDeg;
  int flightLevel;
  int groundSpeedKts;
  double sectorX;
  double sectorY;
  final String entryFix;
  final String exitFix;
  int delayMinutes;

  TrackVector({
    required this.callsign,
    required this.typeCode,
    required this.headingDeg,
    required this.flightLevel,
    required this.groundSpeedKts,
    required this.sectorX,
    required this.sectorY,
    required this.entryFix,
    required this.exitFix,
    this.delayMinutes = 0,
  });

  double get headingRad => headingDeg * math.pi / 180.0;

  TrackVector projected(double minutes) {
    final nmPerMinute = groundSpeedKts / 60.0;
    final span = nmPerMinute * minutes / 120.0;
    final nx = (sectorX + math.sin(headingRad) * span).clamp(-1.0, 1.0);
    final ny = (sectorY - math.cos(headingRad) * span).clamp(-1.0, 1.0);
    return TrackVector(
      callsign: callsign,
      typeCode: typeCode,
      headingDeg: headingDeg,
      flightLevel: flightLevel,
      groundSpeedKts: groundSpeedKts,
      sectorX: nx,
      sectorY: ny,
      entryFix: entryFix,
      exitFix: exitFix,
      delayMinutes: delayMinutes,
    );
  }
}

class ConflictProbe {
  final String callsignA;
  final String callsignB;
  final int minutesAhead;
  final double separationNm;
  final int levelGap;

  const ConflictProbe({
    required this.callsignA,
    required this.callsignB,
    required this.minutesAhead,
    required this.separationNm,
    required this.levelGap,
  });

  bool get critical => separationNm < 0.16 && levelGap < 10;
  bool get advisory => separationNm < 0.28 && levelGap < 10;
}

class SectorFix {
  final String code;
  final double x;
  final double y;
  const SectorFix(this.code, this.x, this.y);
}

class SectorDef {
  final String code;
  final String region;
  final String name;
  final List<SectorFix> fixes;
  const SectorDef(this.code, this.region, this.name, this.fixes);
}

enum OpsSeverity { routine, caution, alert }

class OpsEvent {
  final String id;
  final String headline;
  final String detail;
  final OpsSeverity severity;
  final int costUsd;
  final double carbonKg;
  final DateTime stampedAt;

  const OpsEvent({
    required this.id,
    required this.headline,
    required this.detail,
    required this.severity,
    required this.costUsd,
    required this.carbonKg,
    required this.stampedAt,
  });
}
