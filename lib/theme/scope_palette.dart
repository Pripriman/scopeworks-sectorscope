import 'package:flutter/material.dart';

class ScopePalette {
  static const Color voidBlack = Color(0xFF03070A);
  static const Color scopeBlack = Color(0xFF071013);
  static const Color panel = Color(0xFF0B181C);
  static const Color panelRaised = Color(0xFF102429);
  static const Color grid = Color(0xFF14333A);
  static const Color hairline = Color(0xFF1C4047);

  static const Color phosphor = Color(0xFF36F08A);
  static const Color phosphorDim = Color(0xFF1E8F56);
  static const Color phosphorWash = Color(0xFF0C2A1E);

  static const Color cyan = Color(0xFF34D6E8);
  static const Color cyanDim = Color(0xFF1A7E8C);

  static const Color amber = Color(0xFFF2B53C);
  static const Color amberWash = Color(0xFF2A2310);

  static const Color alertRed = Color(0xFFFF4D4D);
  static const Color alertWash = Color(0xFF2C0E10);

  static const Color readout = Color(0xFFB9F5D6);
  static const Color readoutSoft = Color(0xFF6FA98C);
  static const Color readoutFaint = Color(0xFF3F6B58);

  static const LinearGradient scopeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF071013), Color(0xFF03070A)],
  );

  static const RadialGradient sweepGlow = RadialGradient(
    colors: [Color(0x5536F08A), Color(0x0036F08A)],
  );
}
