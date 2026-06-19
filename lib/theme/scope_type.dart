import 'package:flutter/material.dart';
import 'scope_palette.dart';

class ScopeType {
  static TextStyle _t(
    FontWeight weight,
    double size, {
    double? height,
    double? spacing,
    Color? color,
  }) {
    return TextStyle(
      fontWeight: weight,
      fontSize: size,
      height: height,
      letterSpacing: spacing,
      color: color ?? ScopePalette.readout,
    );
  }

  static TextStyle display({Color? color}) =>
      _t(FontWeight.w800, 26, height: 1.05, spacing: 1.5, color: color);
  static TextStyle title({Color? color}) =>
      _t(FontWeight.w700, 19, height: 1.12, spacing: 1.2, color: color);
  static TextStyle heading({Color? color}) =>
      _t(FontWeight.w700, 15, height: 1.18, spacing: 0.8, color: color);
  static TextStyle body({Color? color}) => _t(FontWeight.w400, 14, height: 1.45,
      color: color ?? ScopePalette.readoutSoft);
  static TextStyle bodyStrong({Color? color}) =>
      _t(FontWeight.w600, 14, height: 1.42, color: color);
  static TextStyle label({Color? color}) => _t(FontWeight.w700, 11,
      spacing: 1.6, color: color ?? ScopePalette.readoutSoft);
  static TextStyle caption({Color? color}) => _t(FontWeight.w600, 11,
      spacing: 0.8, color: color ?? ScopePalette.readoutFaint);

  static TextStyle readout(double size, {Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFamily: 'monospace',
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: weight ?? FontWeight.w700,
        fontSize: size,
        height: 1.0,
        letterSpacing: 1.0,
        color: color ?? ScopePalette.phosphor,
      );

  static TextStyle tag(double size, {Color? color, double spacing = 2.0}) =>
      TextStyle(
        fontFamily: 'monospace',
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: FontWeight.w700,
        fontSize: size,
        height: 1.05,
        letterSpacing: spacing,
        color: color ?? ScopePalette.phosphor,
      );
}
