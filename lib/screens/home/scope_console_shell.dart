import 'dart:async';
import 'package:flutter/material.dart';

import '../../domain/scope_engine.dart';
import '../../domain/sector_catalog.dart';
import '../../runtime/backend_bus.dart';
import '../../runtime/signal_relay.dart';
import '../../theme/scope_palette.dart';
import '../../theme/scope_type.dart';
import '../access/controller_access_screen.dart';
import 'clearance_queue_view.dart';
import 'duty_archive_view.dart';
import 'ops_ledger_view.dart';
import 'predictive_line_view.dart';
import 'scope_board_view.dart';

class ScopeConsoleShell extends StatefulWidget {
  const ScopeConsoleShell({super.key});

  @override
  State<ScopeConsoleShell> createState() => _ScopeConsoleShellState();
}

class _ScopeConsoleShellState extends State<ScopeConsoleShell> {
  late ScopeEngine _engine;
  Timer? _ticker;
  int _station = 0;
  bool _hardcore = false;
  String? _selected;

  static const _titles = [
    'SCOPE',
    'TIMELINE',
    'CLEARANCE',
    'OPS LEDGER',
    'DUTY LOG',
  ];

  @override
  void initState() {
    super.initState();
    _engine = ScopeEngine(SectorCatalog.all.first,
        seed: DateTime.now().millisecondsSinceEpoch ~/ 60000);
    _ticker = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      setState(() => _engine.tick());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _swapSector(int index) {
    setState(() {
      _engine = ScopeEngine(SectorCatalog.all[index],
          seed: DateTime.now().millisecondsSinceEpoch ~/ 1000 + index);
      _selected = null;
    });
  }

  void _toggleHardcore(bool v) => setState(() => _hardcore = v);
  void _pick(String? callsign) => setState(() => _selected = callsign);

  void _openProfile() {
    final signed = BackendBus.onWatch;
    showModalBottomSheet(
      context: context,
      backgroundColor: ScopePalette.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONTROLLER', style: ScopeType.heading()),
                const SizedBox(height: 6),
                Text(
                  signed
                      ? (BackendBus.activeController?.email ?? 'On watch')
                      : 'Operating as a guest controller.',
                  style: ScopeType.body(),
                ),
                const SizedBox(height: 16),
                if (signed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded,
                        color: ScopePalette.alertRed),
                    title: Text('Sign off',
                        style: ScopeType.bodyStrong(
                            color: ScopePalette.alertRed)),
                    onTap: () async {
                      await SignalRelay.dropController();
                      await BackendBus.closeWatch();
                      if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      if (mounted) setState(() {});
                    },
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.login_rounded,
                        color: ScopePalette.cyan),
                    title: Text('Sign on or create profile',
                        style: ScopeType.bodyStrong(color: ScopePalette.cyan)),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ControllerAccessScreen(
                            onDone: () {
                              Navigator.of(context).maybePop();
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_station) {
      case 0:
        body = ScopeBoardView(
          engine: _engine,
          selected: _selected,
          onPick: _pick,
          onSwapSector: _swapSector,
        );
        break;
      case 1:
        body = PredictiveLineView(engine: _engine, selected: _selected, onPick: _pick);
        break;
      case 2:
        body = ClearanceQueueView(engine: _engine, selected: _selected, onPick: _pick);
        break;
      case 3:
        body = OpsLedgerView(engine: _engine);
        break;
      case 4:
        body = DutyArchiveView(
          engine: _engine,
          hardcore: _hardcore,
          onHardcore: _toggleHardcore,
        );
        break;
      default:
        body = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: ScopePalette.voidBlack,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Text(_titles[_station], style: ScopeType.title()),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ScopePalette.phosphorWash,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ScopePalette.phosphorDim),
              ),
              child: Text(_engine.sector.code,
                  style: ScopeType.tag(11, color: ScopePalette.phosphor)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: ScopePalette.readoutSoft,
            onPressed: _openProfile,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: body,
      bottomNavigationBar: _StationBar(
        index: _station,
        onChanged: (i) => setState(() => _station = i),
      ),
    );
  }
}

class _StationBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _StationBar({required this.index, required this.onChanged});

  static const _items = [
    (Icons.radar_rounded, 'Scope'),
    (Icons.timeline_rounded, 'Line'),
    (Icons.alt_route_rounded, 'Clear'),
    (Icons.receipt_long_rounded, 'Ledger'),
    (Icons.workspace_premium_outlined, 'Duty'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ScopePalette.scopeBlack,
        border: Border(top: BorderSide(color: ScopePalette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == index;
              final item = _items[i];
              return Expanded(
                child: InkResponse(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$1,
                        size: 22,
                        color: selected
                            ? ScopePalette.phosphor
                            : ScopePalette.readoutFaint,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2.toUpperCase(),
                        style: ScopeType.caption(
                          color: selected
                              ? ScopePalette.phosphor
                              : ScopePalette.readoutFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
