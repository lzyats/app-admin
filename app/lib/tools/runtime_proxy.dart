import 'dart:math';
import 'package:flutter/foundation.dart';

class RuntimeProxy {
  static bool get enabled => kDebugMode; // Debug-only

  // HTTP proxy（你已在用）
  static bool httpReady = false;
  static int httpPort = 0;

  // WS proxy
  static bool wsReady = false;
  static int wsPort = 0;

  static final String authToken = _randToken(24);

  static String httpBaseUrl() => "http://127.0.0.1:$httpPort";
  static String wsBaseUrl() => "ws://127.0.0.1:$wsPort";

  static String _randToken(int len) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random.secure();
    return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
  }
}