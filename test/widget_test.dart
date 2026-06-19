import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sectorscope/domain/scope_engine.dart';
import 'package:sectorscope/domain/sector_catalog.dart';
import 'package:sectorscope/widgets/track_blip.dart';

void main() {
  testWidgets('TrackBlip renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: TrackBlip(size: 60)),
        ),
      ),
    );
    expect(find.byType(TrackBlip), findsOneWidget);
  });

  test('scope engine spawns traffic and detects conflicts', () {
    final engine = ScopeEngine(SectorCatalog.all.first, seed: 3);
    expect(engine.tracks.length, greaterThan(0));
    final probes = engine.probeAhead(30);
    expect(probes, isA<List>());
  });

  test('clearance assigns flight level within bounds', () {
    final engine = ScopeEngine(SectorCatalog.all.first, seed: 9);
    final cs = engine.tracks.first.callsign;
    engine.assignFlightLevel(cs, 999);
    expect(engine.byCallsign(cs)!.flightLevel, lessThanOrEqualTo(430));
  });
}
