import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'duty_record.dart';

class DutyArchive extends ChangeNotifier {
  static const _storeKey = 'scope.duty_records';
  static const _uuid = Uuid();

  final List<DutyRecord> _records = [];
  bool _loaded = false;

  List<DutyRecord> get records => List.unmodifiable(_records);
  bool get isLoaded => _loaded;

  int get watchesLogged => _records.length;

  int get trafficTotal =>
      _records.fold(0, (sum, r) => sum + r.trafficHandled);

  int get conflictsTotal =>
      _records.fold(0, (sum, r) => sum + r.conflictsResolved);

  int get careerRating => _records.fold(0, (sum, r) => sum + r.rating);

  Set<String> get sectorsWorked =>
      _records.map((r) => r.sectorCode).where((s) => s.isNotEmpty).toSet();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    _records.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final e in list) {
          _records.add(DutyRecord.fromJson(e as Map<String, dynamic>));
        }
      } catch (_) {}
    }
    _records.sort((a, b) => b.flownAt.compareTo(a.flownAt));
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_records.map((e) => e.toJson()).toList());
    await prefs.setString(_storeKey, encoded);
  }

  Future<DutyRecord> fileWatch({
    required String sectorCode,
    required int trafficHandled,
    required int conflictsResolved,
    required int costUsd,
    required double carbonKg,
    required bool hardcore,
  }) async {
    final record = DutyRecord(
      id: _uuid.v4(),
      flownAt: DateTime.now(),
      sectorCode: sectorCode,
      trafficHandled: trafficHandled,
      conflictsResolved: conflictsResolved,
      costUsd: costUsd,
      carbonKg: carbonKg,
      hardcore: hardcore,
    );
    _records.insert(0, record);
    await _persist();
    notifyListeners();
    return record;
  }

  Future<void> strike(String id) async {
    _records.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  Map<String, int> watchesBySector() {
    final map = <String, int>{};
    for (final r in _records) {
      if (r.sectorCode.isEmpty) continue;
      map[r.sectorCode] = (map[r.sectorCode] ?? 0) + 1;
    }
    return map;
  }
}
