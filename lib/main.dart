import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'domain/duty_archive.dart';
import 'runtime/backend_bus.dart';
import 'runtime/signal_relay.dart';
import 'runtime/trace_beacon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await BackendBus.boot();
  } catch (_) {}

  await SignalRelay.boot();
  TraceBeacon.boot();

  final archive = DutyArchive();
  await archive.load();

  await _markFirstOpen();

  runApp(SectorScopeApp(archive: archive));
}

Future<void> _markFirstOpen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const key = 'scope.first_open_sent';
    if (!(prefs.getBool(key) ?? false)) {
      TraceBeacon.firstOpen();
      await prefs.setBool(key, true);
    }
  } catch (_) {}
}
