import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myapp/request/app_config_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBootstrapTool {
  AppBootstrapTool._();

  static const String _cacheKey = 'app.bootstrap.config.v2';
  static final ValueNotifier<AppBootstrapConfigData> configNotifier =
      ValueNotifier<AppBootstrapConfigData>(AppBootstrapConfigData.defaults);
  static bool _initialized = false;

  static AppBootstrapConfigData get config => configNotifier.value;

  static Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cached = (prefs.getString(_cacheKey) ?? '').trim();
    if (cached.isNotEmpty) {
      try {
        final dynamic json = jsonDecode(cached);
        if (json is Map<String, dynamic>) {
          configNotifier.value = AppBootstrapConfigData.fromJson(json);
        }
      } catch (_) {}
    }

    unawaited(refreshRemote());
  }

  static Future<void> refreshRemote() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final AppBootstrapConfigData remote = await AppConfigApi.bootstrap();
      configNotifier.value = remote;
      await prefs.setString(_cacheKey, jsonEncode(remote.toJson()));
    } catch (_) {}
  }
}
