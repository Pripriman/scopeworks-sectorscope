import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'access/controller_access_screen.dart';
import 'home/scope_console_shell.dart';
import 'intro/briefing_deck.dart';

enum _Stage { boot, intro, access, home }

class NativeRoot extends StatefulWidget {
  const NativeRoot({super.key});

  @override
  State<NativeRoot> createState() => _NativeRootState();
}

class _NativeRootState extends State<NativeRoot> {
  static const _briefingKey = 'scope.briefing_complete';
  _Stage _stage = _Stage.boot;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_briefingKey) ?? false;
    if (!mounted) return;
    setState(() => _stage = done ? _Stage.home : _Stage.intro);
  }

  Future<void> _finishBriefing() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_briefingKey, true);
    if (!mounted) return;
    setState(() => _stage = _Stage.access);
  }

  void _finishAccess() => setState(() => _stage = _Stage.home);

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _Stage.boot:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case _Stage.intro:
        return BriefingDeck(onDone: _finishBriefing);
      case _Stage.access:
        return ControllerAccessScreen(onDone: _finishAccess);
      case _Stage.home:
        return const ScopeConsoleShell();
    }
  }
}
