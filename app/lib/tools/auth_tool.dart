import 'package:flutter/foundation.dart';

class AuthTool {
  static final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);

  static bool get isLogin => tokenNotifier.value != null && tokenNotifier.value!.isNotEmpty;

  static Future<void> login(String token) async {
    tokenNotifier.value = token;
  }

  static Future<void> logout() async {
    tokenNotifier.value = null;
  }
}
