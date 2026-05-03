import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语言设置工具类，用于持久化用户选择的应用语言。
class LocaleTool {
  LocaleTool._();

  static const String _localeKey = 'app.locale';

  /// 读取已保存的语言设置。
  /// 返回 null 表示跟随系统。
  static Future<Locale?> loadLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = (prefs.getString(_localeKey) ?? '').trim();
    if (raw.isEmpty || raw == 'system') {
      return null;
    }

    final List<String> parts = raw.split('_');
    if (parts.isEmpty || parts.first.isEmpty) {
      return null;
    }

    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  /// 保存语言设置。
  /// locale 为 null 时表示跟随系统。
  static Future<void> saveLocale(Locale? locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString(_localeKey, 'system');
      return;
    }
    final String country = (locale.countryCode ?? '').trim();
    final String value =
        country.isEmpty ? locale.languageCode : '${locale.languageCode}_$country';
    await prefs.setString(_localeKey, value);
  }
}

