import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp/config/app_config.dart';

class LineHostTool {
  const LineHostTool._();

  static const String _cacheKeyHttpUrl = 'line_selected_http_url';
  static const String _cacheKeyCustomHosts = 'line_custom_hosts_json';

  /// 读取当前生效线路，缓存为空时回退默认线路。
  static Future<RequestHost> getCurrentHost() async {
    final List<RequestHost> allHosts = await getAllHosts();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cachedHttpUrl = (prefs.getString(_cacheKeyHttpUrl) ?? '').trim();

    if (cachedHttpUrl.isEmpty) {
      return AppConfig.defaultRequestHost;
    }

    for (final RequestHost host in allHosts) {
      if (host.httpUrl == cachedHttpUrl) {
        return host;
      }
    }

    return AppConfig.defaultRequestHost;
  }

  /// 保存当前生效线路到本地缓存。
  static Future<void> setCurrentHost(RequestHost host) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKeyHttpUrl, host.httpUrl);
  }

  /// 获取“内置线路 + 自定义线路”的完整列表。
  static Future<List<RequestHost>> getAllHosts() async {
    final List<RequestHost> result = <RequestHost>[
      ...AppConfig.requestHost,
      ...await getCustomHosts(),
    ];
    return result;
  }

  /// 获取本地缓存的自定义线路列表。
  static Future<List<RequestHost>> getCustomHosts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = (prefs.getString(_cacheKeyCustomHosts) ?? '').trim();
    if (raw.isEmpty) {
      return <RequestHost>[];
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <RequestHost>[];
      }
      final List<RequestHost> result = <RequestHost>[];
      for (final dynamic item in decoded) {
        if (item is Map<String, dynamic>) {
          final RequestHost? host = RequestHost.fromJson(item);
          if (host != null) {
            result.add(host);
          }
        } else if (item is Map) {
          final RequestHost? host = RequestHost.fromJson(Map<String, dynamic>.from(item));
          if (host != null) {
            result.add(host);
          }
        }
      }
      return result;
    } catch (_) {
      return <RequestHost>[];
    }
  }

  /// 新增一条自定义线路（自动去重）。
  static Future<bool> addCustomHost(RequestHost host) async {
    final List<RequestHost> allHosts = await getAllHosts();
    for (final RequestHost item in allHosts) {
      if (item.httpUrl == host.httpUrl && item.wsUrl == host.wsUrl) {
        return false;
      }
    }

    final List<RequestHost> customHosts = await getCustomHosts();
    customHosts.add(host);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = jsonEncode(customHosts.map((RequestHost e) => e.toJson()).toList());
    await prefs.setString(_cacheKeyCustomHosts, raw);
    return true;
  }

  /// 清除当前线路缓存标记。
  static Future<void> clearCurrentHost() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKeyHttpUrl);
  }
}
