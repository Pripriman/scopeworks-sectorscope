import 'package:affise_attribution_lib/affise.dart';
import '../config/scope_env.dart';

class TraceBeacon {
  static bool _started = false;

  static void boot() {
    if (_started || !ScopeEnv.hasBeacon) return;
    try {
      Affise
          .settings(
            affiseAppId: ScopeEnv.affiseAppId,
            secretKey: ScopeEnv.affiseSecret,
          )
          .setProduction(true)
          .start();
      _started = true;
    } catch (_) {}
  }

  static void _emit(String name) {
    if (!_started) return;
    try {
      Affise.sendEvent(UserCustomEvent(eventName: name));
    } catch (_) {}
  }

  static void firstOpen() => _emit('first_open');
  static void registration() => _emit('registration');
  static void login() => _emit('login');
  static void contentOpen() => _emit('content_open');
}
