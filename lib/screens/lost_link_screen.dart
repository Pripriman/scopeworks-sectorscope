import 'package:flutter/material.dart';
import '../theme/scope_palette.dart';
import '../theme/scope_type.dart';
import '../widgets/sweep_button.dart';

class LostLinkScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const LostLinkScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ScopePalette.scopeGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: ScopePalette.alertWash,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ScopePalette.alertRed),
                  ),
                  child: const Icon(Icons.sensors_off_rounded,
                      size: 36, color: ScopePalette.alertRed),
                ),
                const SizedBox(height: 24),
                Text('SECTOR LINK LOST',
                    style: ScopeType.title(color: ScopePalette.alertRed),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(
                  'No handshake with control. Check your connection and re-acquire the sector feed.',
                  style: ScopeType.body(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SweepButton(
                  label: 'Re-acquire',
                  icon: Icons.refresh_rounded,
                  expand: false,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
