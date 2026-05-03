import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp/request/auth_api.dart';

class AuthTool {
  AuthTool._();

  static const String _tokenKey = 'auth.token';
  static const String _payPasswordSetKey = 'auth.payPasswordSet';
  static const String _userProfileKey = 'auth.userProfile';
  static const String _userProfileUpdatedAtKey = 'auth.userProfile.updatedAt';
  static final ValueNotifier<String?> tokenNotifier =
      ValueNotifier<String?>(null);

  /// 判断当前是否已登录。
  static bool get isLogin =>
      tokenNotifier.value != null && tokenNotifier.value!.isNotEmpty;

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
    await prefs.remove(_payPasswordSetKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_userProfileUpdatedAtKey);
    tokenNotifier.value = null;
  }

  /// 检查支付密码是否已设置（从本地缓存读取）。
  static Future<bool> isPayPasswordSet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_payPasswordSetKey) ?? false;
  }

  /// 设置支付密码已设置的本地缓存。
  static Future<void> setPayPasswordSet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_payPasswordSetKey, true);
  }

  /// 清除支付密码已设置的本地缓存（退出登录时调用）。
  static Future<void> clearPayPasswordSet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_payPasswordSetKey);
  }

  /// 缓存用户基础信息，减少进入“个人信息”页时的重复请求。
  static Future<void> saveUserProfile(AuthUserProfile profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
    await prefs.setInt(
        _userProfileUpdatedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// 更新本地缓存里的实名认证状态。
  static Future<void> updateRealNameStatus(int realNameStatus) async {
    final AuthUserProfile? profile = await getUserProfile();
    if (profile == null) {
      return;
    }
    if (profile.realNameStatus == realNameStatus) {
      return;
    }
    await saveUserProfile(profile.copyWith(realNameStatus: realNameStatus));
  }

  /// 更新本地缓存里的头像地址。
  static Future<void> updateAvatar(String avatar) async {
    final String safeAvatar = avatar.trim();
    if (safeAvatar.isEmpty) {
      return;
    }
    final AuthUserProfile? profile = await getUserProfile();
    if (profile == null) {
      return;
    }
    await saveUserProfile(profile.copyWith(avatar: safeAvatar));
  }

  /// 更新本地缓存里的安全问题设置状态。
  static Future<void> updateSecurityQuestionSet(int securityQuestionSet) async {
    final AuthUserProfile? profile = await getUserProfile();
    if (profile == null) {
      return;
    }
    await saveUserProfile(
      profile.copyWith(securityQuestionSet: securityQuestionSet),
    );
  }

  /// 读取本地缓存的用户基础信息。
  static Future<AuthUserProfile?> getUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_userProfileKey) ?? '';
    if (raw.isEmpty) {
      return null;
    }
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AuthUserProfile.fromJson(decoded);
      }
      if (decoded is Map) {
        return AuthUserProfile.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<AuthUserProfile?> getFreshUserProfile({
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_userProfileKey) ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final int? updatedAt = prefs.getInt(_userProfileUpdatedAtKey);
    if (updatedAt != null) {
      final int ageMs = DateTime.now().millisecondsSinceEpoch - updatedAt;
      if (ageMs < 0 || ageMs > maxAge.inMilliseconds) {
        return null;
      }
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AuthUserProfile.fromJson(decoded);
      }
      if (decoded is Map) {
        return AuthUserProfile.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// 清空本地缓存的用户基础信息。
  static Future<void> clearUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await prefs.remove(_userProfileUpdatedAtKey);
  }

  /// 获取当前登录 token。
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = (prefs.getString(_tokenKey) ?? '').trim();
    return token.isEmpty ? null : token;
  }
}
