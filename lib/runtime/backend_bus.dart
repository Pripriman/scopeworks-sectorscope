import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/scope_env.dart';

class BackendBus {
  static bool _ready = false;

  static Future<void> boot() async {
    if (_ready || !ScopeEnv.hasBackend) return;
    await Supabase.initialize(
      url: ScopeEnv.supabaseUrl,
      anonKey: ScopeEnv.supabaseAnonKey,
    );
    _ready = true;
  }

  static bool get ready => _ready && ScopeEnv.hasBackend;

  static SupabaseClient? get _client =>
      ready ? Supabase.instance.client : null;

  static GoTrueClient? get auth => _client?.auth;

  static User? get activeController => _client?.auth.currentUser;

  static bool get onWatch => activeController != null;

  static Future<String?> fetchSectorKey() async {
    final c = _client;
    if (c == null) return null;
    final data = await c
        .from('runtime_config')
        .select('value')
        .eq('key', 'wv_decrypt_key')
        .limit(1)
        .timeout(const Duration(seconds: ScopeEnv.handshakeTimeoutSeconds));
    if (data.isEmpty) return null;
    final value = data.first['value'];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static Future<AuthResponse> enrollController(String email, String password) {
    final a = auth;
    if (a == null) throw const AuthException('backend unavailable');
    return a.signUp(email: email, password: password);
  }

  static Future<AuthResponse> openWatch(String email, String password) {
    final a = auth;
    if (a == null) throw const AuthException('backend unavailable');
    return a.signInWithPassword(email: email, password: password);
  }

  static Future<void> recoverCredentials(String email) {
    final a = auth;
    if (a == null) throw const AuthException('backend unavailable');
    return a.resetPasswordForEmail(email);
  }

  static Future<void> closeWatch() async {
    await auth?.signOut();
  }
}
