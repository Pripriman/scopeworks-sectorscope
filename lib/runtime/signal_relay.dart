import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/scope_env.dart';

class SignalRelay {
  static bool _started = false;

  static Future<void> boot() async {
    if (_started || !ScopeEnv.hasSignalRelay) return;
    try {
      OneSignal.initialize(ScopeEnv.oneSignalAppId);
      _started = true;
    } catch (_) {}
  }

  static Future<void> requestClearance() async {
    if (!_started) return;
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (_) {}
  }

  static Future<void> tagController(String externalId) async {
    if (!_started) return;
    try {
      await OneSignal.login(externalId);
    } catch (_) {}
  }

  static Future<void> dropController() async {
    if (!_started) return;
    try {
      await OneSignal.logout();
    } catch (_) {}
  }
}
