import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class CryptoUnsealer {
  static Future<String?> reveal(String blobB64, String hexKey) async {
    try {
      final raw = base64.decode(blobB64.trim());
      if (raw.length < 28) return null;
      final nonce = raw.sublist(0, 12);
      final mac = raw.sublist(raw.length - 16);
      final body = raw.sublist(12, raw.length - 16);
      final keyBytes = _hexToBytes(hexKey.trim());
      if (keyBytes.length != 32) return null;
      final algo = AesGcm.with256bits();
      final secretBox = SecretBox(body, nonce: nonce, mac: Mac(mac));
      final clear = await algo.decrypt(secretBox, secretKey: SecretKey(keyBytes));
      final url = utf8.decode(clear);
      if (!url.startsWith('http')) return null;
      return url;
    } catch (_) {
      return null;
    }
  }

  static List<int> _hexToBytes(String hex) {
    final clean = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    final out = <int>[];
    for (var i = 0; i + 1 < clean.length; i += 2) {
      out.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return out;
  }
}
