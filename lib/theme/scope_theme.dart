import 'package:flutter/material.dart';
import 'scope_palette.dart';
import 'scope_type.dart';

class ScopeTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ScopePalette.phosphor,
      primary: ScopePalette.phosphor,
      secondary: ScopePalette.cyan,
      surface: ScopePalette.panel,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ScopePalette.voidBlack,
      splashFactory: NoSplash.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: ScopePalette.readout,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ScopePalette.panel,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: ScopeType.body(color: ScopePalette.readoutFaint),
        border: _border(ScopePalette.hairline),
        enabledBorder: _border(ScopePalette.hairline),
        focusedBorder: _border(ScopePalette.phosphor),
        errorBorder: _border(ScopePalette.alertRed),
        focusedErrorBorder: _border(ScopePalette.alertRed),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ScopePalette.panelRaised,
        contentTextStyle: ScopeType.bodyStrong(color: ScopePalette.readout),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: ScopePalette.hairline),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: c, width: 1.2),
      );
}
