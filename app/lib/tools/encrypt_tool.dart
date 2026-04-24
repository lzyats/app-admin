import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import '../config/app_config.dart';

class EncryptTool {
  const EncryptTool._();

  static final Key _key = Key.fromUtf8(AppConfig.aesKey);
  static final IV _iv = IV.fromUtf8(AppConfig.aesIv);
  static final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc, padding: 'PKCS7'));

  static String encryptAny(dynamic raw) {
    final String text = raw is String ? raw : jsonEncode(raw);
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  static dynamic decryptAny(dynamic encryptedValue) {
    if (encryptedValue == null) {
      return null;
    }

    final String encryptedText = encryptedValue.toString();
    final String plain = _encrypter.decrypt64(encryptedText, iv: _iv);
    try {
      return jsonDecode(plain);
    } catch (_) {
      return plain;
    }
  }

  static String sign({
    required String appId,
    required String secret,
    required String timestamp,
    required String pathWithQuery,
  }) {
    final String raw = '$appId$secret$timestamp$pathWithQuery';
    return sha256.convert(utf8.encode(raw)).toString();
  }
}
