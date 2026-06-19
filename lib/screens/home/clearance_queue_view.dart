import 'package:flutter/material.dart';

import '../../domain/scope_engine.dart';
import '../../theme/scope_palette.dart';
import '../../theme/scope_type.dart';
import '../../widgets/scope_panel.dart';
import '../../widgets/sweep_button.dart';

class ClearanceQueueView extends StatefulWidget {
  final ScopeEngine engine;
  final String? selected;
  final ValueChanged<String?> onPick;

  const ClearanceQueueView({
    super.key,
    required this.engine,
    required this.selected,
    required this.onPick,
  });

  @override
  State<ClearanceQueueView> createState() => _ClearanceQueueViewState();
}

class _ClearanceQueueViewState extends State<ClearanceQueueView> {
  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final engine = widget.engine;
    final track =
        widget.selected == null ? null : engine.byCallsign(widget.selected!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text('CLEARANCE QUEUE', style: ScopeType.label()),
        const SizedBox(height: 10),
        ...engine.tracks.map((t) {
          final selected = t.callsign == widget.selected;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ScopePanel(
              onTap: () => widget.onPick(t.callsign),
              color: selected ? ScopePalette.panelRaised : ScopePalette.panel,
              border: Border.all(
                color: selected ? ScopePalette.cyan : ScopePalette.hairline,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(t.callsign,
                            style: ScopeType.tag(14,
                                color: selected
                                    ? ScopePalette.cyan
                                    : ScopePalette.phosphor)),
                        const SizedBox(width: 10),
                        Text(t.typeCode, style: ScopeType.caption()),
                      ],
                    ),
                  ),
                  Text('FL${t.flightLevel}',
                      style: ScopeType.readout(13, color: ScopePalette.readout)),
                  const SizedBox(width: 12),
                  Text('${t.groundSpeedKts}KT',
                      style: ScopeType.readout(13,
                          color: ScopePalette.readoutSoft)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
        if (track == null)
          ScopePanel(
            color: ScopePalette.phosphorWash,
            border: Border.all(color: ScopePalette.phosphorDim),
            child: Row(
              children: [
                const Icon(Icons.touch_app_outlined,
                    color: ScopePalette.phosphor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Select a track to issue clearances.',
                      style: ScopeType.bodyStrong(color: ScopePalette.phosphor)),
                ),
              ],
            ),
          )
        else
          _commandPanel(track),
      ],
    );
  }

  Widget _commandPanel(track) {
    return ScopePanel(
      border: Border.all(color: ScopePalette.cyan),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ISSUE CLEARANCE · ${track.callsign}',
              style: ScopeType.heading(color: ScopePalette.cyan)),
          const SizedBox(height: 14),
          _stepperRow('FLIGHT LEVEL', 'FL${track.flightLevel}', () {
            widget.engine.assignFlightLevel(track.callsign, track.flightLevel - 10);
            setState(() {});
            _toast('${track.callsign} descend FL${track.flightLevel}');
          }, () {
            widget.engine.assignFlightLevel(track.callsign, track.flightLevel + 10);
            setState(() {});
            _toast('${track.callsign} climb FL${track.flightLevel}');
          }),
          const SizedBox(height: 12),
          _stepperRow('SPEED', '${track.groundSpeedKts} KT', () {
            widget.engine.assignSpeed(track.callsign, track.groundSpeedKts - 20);
            setState(() {});
          }, () {
            widget.engine.assignSpeed(track.callsign, track.groundSpeedKts + 20);
            setState(() {});
          }),
          const SizedBox(height: 12),
          _stepperRow('HEADING',
              track.headingDeg.round().toString().padLeft(3, '0'), () {
            widget.engine
                .assignHeading(track.callsign, (track.headingDeg.round() - 15) % 360);
            setState(() {});
          }, () {
            widget.engine
                .assignHeading(track.callsign, (track.headingDeg.round() + 15) % 360);
            setState(() {});
          }),
          const SizedBox(height: 16),
          SweepButton(
            label: 'Hold in stack',
            icon: Icons.cyclone_rounded,
            tint: ScopePalette.amber,
            onPressed: () {
              widget.engine.holdTrack(track.callsign);
              setState(() {});
              _toast('${track.callsign} entering holding pattern');
            },
          ),
        ],
      ),
    );
  }

  Widget _stepperRow(
      String label, String value, VoidCallback onDown, VoidCallback onUp) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(label, style: ScopeType.label()),
        ),
        _stepBtn(Icons.remove_rounded, onDown),
        Expanded(
          child: Center(
            child: Text(value,
                style: ScopeType.readout(18, color: ScopePalette.readout)),
          ),
        ),
        _stepBtn(Icons.add_rounded, onUp),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ScopePalette.phosphorWash,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ScopePalette.phosphorDim),
          ),
          child: Icon(icon, size: 18, color: ScopePalette.phosphor),
        ),
      ),
    );
  }
}
