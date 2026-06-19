import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/scope_engine.dart';
import '../../domain/track_models.dart';
import '../../theme/scope_palette.dart';
import '../../theme/scope_type.dart';
import '../../widgets/scope_panel.dart';

class OpsLedgerView extends StatelessWidget {
  final ScopeEngine engine;
  const OpsLedgerView({super.key, required this.engine});

  Color _sevColor(OpsSeverity s) {
    switch (s) {
      case OpsSeverity.alert:
        return ScopePalette.alertRed;
      case OpsSeverity.caution:
        return ScopePalette.amber;
      case OpsSeverity.routine:
        return ScopePalette.phosphor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usd = NumberFormat.decimalPattern();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: _costCard('COST OF ERROR', '\$${usd.format(engine.costUsd)}',
                  ScopePalette.alertRed, Icons.payments_outlined),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _costCard('CARBON',
                  '${engine.carbonKg.round()} KG', ScopePalette.amber,
                  Icons.co2_outlined),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('SECTOR EVENT LOG', style: ScopeType.label()),
        const SizedBox(height: 10),
        if (engine.log.isEmpty)
          ScopePanel(
            child: Row(
              children: [
                const Icon(Icons.history_toggle_off_rounded,
                    color: ScopePalette.readoutFaint, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No sector events yet. Storms, failures and intercepts will appear here as the watch runs.',
                    style: ScopeType.body(),
                  ),
                ),
              ],
            ),
          )
        else
          ...engine.log.map((e) {
            final color = _sevColor(e.severity);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ScopePanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 38,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      color: color,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(e.headline.toUpperCase(),
                                    style: ScopeType.heading(color: color)),
                              ),
                              Text(DateFormat('HH:mm:ss').format(e.stampedAt),
                                  style: ScopeType.readout(11,
                                      color: ScopePalette.readoutFaint)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(e.detail, style: ScopeType.body()),
                          if (e.costUsd > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                              '−\$${NumberFormat.decimalPattern().format(e.costUsd)} · ${e.carbonKg.round()} kg CO₂',
                              style: ScopeType.caption(color: color),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _costCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ScopePalette.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(value, style: ScopeType.readout(20, color: color)),
          const SizedBox(height: 4),
          Text(label, style: ScopeType.caption()),
        ],
      ),
    );
  }
}
