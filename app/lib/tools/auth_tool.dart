import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTool {
  AuthTool._();

  static const String _tokenKey = 'auth.token';
  static final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);

  /// 判断当前是否已登录。
  static bool get isLogin => tokenNotifier.value != null && tokenNotifier.value!.isNotEmpty;

  /// 初始化认证状态，启动时从本地缓存恢复 token。
  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = (prefs.getString(_tokenKey) ?? '').trim();
    tokenNotifier.value = token.isEmpty ? null : token;
  }

  /// 写入登录 token。
  static Future<void> login(String token) async {
    final String safeToken = token.trim();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, safeToken);
    tokenNotifier.value = safeToken.isEmpty ? null : safeToken;
  }

  /// 清空登录 token 并退出登录状态。
  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    tokenNotifier.value = null;
  }
}
