class DutyRecord {
  final String id;
  DateTime flownAt;
  String sectorCode;
  int trafficHandled;
  int conflictsResolved;
  int costUsd;
  double carbonKg;
  bool hardcore;

  DutyRecord({
    required this.id,
    required this.flownAt,
    required this.sectorCode,
    required this.trafficHandled,
    required this.conflictsResolved,
    required this.costUsd,
    required this.carbonKg,
    this.hardcore = false,
  });

  int get rating {
    final penalty = (costUsd / 1000).round();
    final base = conflictsResolved * 40 + trafficHandled * 6;
    final score = base - penalty + (hardcore ? 120 : 0);
    return score < 0 ? 0 : score;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'flownAt': flownAt.toIso8601String(),
        'sector': sectorCode,
        'traffic': trafficHandled,
        'conflicts': conflictsResolved,
        'cost': costUsd,
        'carbon': carbonKg,
        'hardcore': hardcore,
      };

  static DutyRecord fromJson(Map<String, dynamic> j) => DutyRecord(
        id: j['id'] as String,
        flownAt: DateTime.parse(j['flownAt'] as String),
        sectorCode: j['sector'] as String? ?? '',
        trafficHandled: j['traffic'] as int? ?? 0,
        conflictsResolved: j['conflicts'] as int? ?? 0,
        costUsd: j['cost'] as int? ?? 0,
        carbonKg: (j['carbon'] as num?)?.toDouble() ?? 0,
        hardcore: j['hardcore'] as bool? ?? false,
      );
}
