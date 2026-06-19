import 'package:flutter/material.dart';

import 'domain/duty_archive.dart';
import 'screens/preflight_gate_screen.dart';
import 'state/duty_scope.dart';
import 'theme/scope_theme.dart';

class SectorScopeApp extends StatelessWidget {
  final DutyArchive archive;
  const SectorScopeApp({super.key, required this.archive});

  @override
  Widget build(BuildContext context) {
    return DutyScope(
      archive: archive,
      child: MaterialApp(
        title: 'Sector Scope',
        debugShowCheckedModeBanner: false,
        theme: ScopeTheme.build(),
        home: const PreflightGateScreen(),
      ),
    );
  }
}
