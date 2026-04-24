import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import 'package:myapp/config/app_config.dart';

class EncryptTool {
  const EncryptTool._();

  static final Key _key = Key.fromUtf8(AppConfig.aesKey);
  static final IV _iv = IV.fromUtf8(AppConfig.aesIv);
  static final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc, padding: 'PKCS7'));

  /// 对任意对象做 AES 加密并返回 Base64 文本。
  static String encryptAny(dynamic raw) {
    final String text = raw is String ? raw : jsonEncode(raw);
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  /// 对 Base64 密文做 AES 解密，优先尝试解析 JSON。
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

  /// 生成请求签名字符串。
  static String sign({
    required String appId,
    required String secret,
    required String timestamp,
    required String pathWithQuery,
  }) {
    final String raw = '$appId$secret$timestamp$pathWithQuery';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  /// 使用线路二维码专用密钥加密明文。
  static String encryptLineQrText(String plainText) {
    final _LineQrCipher cipher = _LineQrCipher.fromSeed(AppConfig.lineQrCryptoSeed);
    return cipher.encrypter.encrypt(plainText, iv: cipher.iv).base64;
  }

  /// 使用线路二维码专用密钥解密密文。
  static String decryptLineQrText(String cipherText) {
    final _LineQrCipher cipher = _LineQrCipher.fromSeed(AppConfig.lineQrCryptoSeed);
    return cipher.encrypter.decrypt64(cipherText, iv: cipher.iv);
  }
}

class _LineQrCipher {
  /// 创建线路二维码加密器对象。
  _LineQrCipher({
    required this.encrypter,
    required this.iv,
  });

  final Encrypter encrypter;
  final IV iv;

  /// 根据种子派生 key/iv 并构造加密器。
  factory _LineQrCipher.fromSeed(String seed) {
    final List<int> keyBytes = sha256.convert(utf8.encode(seed)).bytes;
    final List<int> ivBytes = md5.convert(utf8.encode(seed)).bytes;
    final Key key = Key(Uint8List.fromList(keyBytes));
    final IV iv = IV(Uint8List.fromList(ivBytes));
    return _LineQrCipher(
      encrypter: Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7')),
      iv: iv,
    );
  }
}
